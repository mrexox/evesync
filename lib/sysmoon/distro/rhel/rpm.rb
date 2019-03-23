require 'hashdiff'
require 'sysmoon/log'
# FIXME: move Package packing into another class
require 'sysmoon/ipc/data/package'

module Sysmoon
  module Distro

    # = Synopsis:
    #
    # Rpm packages changes watcher. Yum history makes it
    # difficult to handler package removals. So, rpm is
    # the only tool that show all packages in the system.
    # This class handles packages changes.
    #
    # = Example:
    #   rpm = Sysmoon::Rpm.new
    #   sleep 1000
    #   rpm.changed.each do |package|
    #     p package # print packages that changed
    #   end
    #
    # = TODO:
    #  * add reinstall handling also
    #
    class Rpm

      # Query for rpm list
      PKG_QUERY = 'rpm -qa --queryformat "%{NAME} %{VERSION}-%{RELEASE}.%{ARCH}\n"'

      private_constant :PKG_QUERY

      def initialize
        @packages = make_pkg_snapshot
      end

      def changes
        # make hash of all packages
        rpms = make_pkg_snapshot
        # diff with last version
        diff = HashDiff.diff(@packages, rpms)
        # parse changes into IPC::Data::Package array
        packages = parse_pkg_diff(diff)
        # use new hash as default
        # FIXME: wait if the changes were saved
        #        and properly handled
        @packages = rpms
        return packages
      end

      private

      # Parses `rpm -qa` into hash {'pkg' => 'version'}
      def make_pkg_snapshot
        snapshot = {}
        rpm_output = `#{PKG_QUERY}`
        rpm_output.lines.each do |line|
          info = line.split
          snapshot[info[0]] = info[1]
        end

        snapshot
      end

      # Parses changes, given by 'hashdiff' gem into
      # IPC::Data::Package array
      def parse_pkg_diff(diffs)
        packages = []
        diffs.each do |diff|
          package = case diff[0]
                    when '-' then removed_package(diff)
                    when '+' then installed_package(diff)
                    when '~' then updated_package(diff)
                    end
          packages.push(package)
        end

        packages
      end

      def removed_package(diff)
        IPC::Data::Package.new(
          name: diff[1],
          version: diff[2],
          command: IPC::Data::Package::Command::REMOVE
        )
      end

      def installed_package(diff)
        IPC::Data::Package.new(
          name: diff[1],
          version: diff[2],
          command: IPC::Data::Package::Command::INSTALL
        )
      end

      def updated_package(diff)
        command = if pkg_version_less(diff[2], diff[3])
                    IPC::Data::Package::Command::UPDATE
                  else
                    IPC::Data::Package::Command::DOWNGRADE
                  end

        IPC::Data::Package.new(
          name: diff[1],
          version: diff[3],
          command: command
        )
      end

      # FIXME: research about restrictions and make sure this work
      def pkg_version_less(a, b)
        a < b
      end

    end
  end
end
