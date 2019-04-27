require 'hashdiff'
require 'evesync/ipc/data/package'

module Evesync
  module Distro
    module BasePackageManager
      def initialize
        @packages = make_pkg_snapshot
      end

      def changes
        # make hash of all packages
        snapshot = make_pkg_snapshot
        # diff with last version
        diff = HashDiff.diff(@packages, snapshot)
        # parse changes into IPC::Data::Package array
        packages = parse_pkg_diff(diff)
        # use new hash as default
        # FIXME: wait if the changes were saved
        #        and properly handled
        @packages = snapshot
        packages
      end

      private

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

      # FIXME:
      #   - research about restrictions and make sure this work
      def pkg_version_less(a, b)
        a < b
      end
    end
  end
end
