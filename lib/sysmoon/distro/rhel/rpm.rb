require 'hashdiff'
require 'sysmoon/ipc_data/package'

module Sysmoon
  # Rpm packages changes watcher.
  # Yum history makes it difficult to handler package removals.
  # So, rpm is the only tool that show all packages in the system.
  # This class handles packages changes.
  # TODO: add reinstall handling also

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
      # parse changes into Package array
      packages = parse_pkg_diff(diff)
      # use new hash as default
      @packages = rpms # FIXME: wait if the changes were saved and properly handled
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

    # Parses changes, given by 'hashdiff' gem into Package array
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
      Package.new(
        name: diff[1],
        version: diff[2],
        command: Package::Command::REMOVE
      )
    end

    def installed_package(diff)
      Package.new(
        name: diff[1],
        version: diff[2],
        command: Package::Command::INSTALL
      )
    end

    def updated_package(diff)
      command = if pkg_version_less(diff[2], diff[3])
                  Package::Command::UPDATE
                else
                  Package::Command::DOWNGRADE
                end

      Package.new(
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
