require 'evesync/log'
require 'evesync/os/linux/base_package_manager'

module Evesync
  module OS

    # Rpm packages changes watcher. Yum history makes it
    # difficult to handler package removals. So, rpm is
    # the only tool that show all packages in the system.
    # This class handles packages changes.
    #
    # = Example:
    #   rpm = Evesync::Rpm.new
    #   sleep 1000
    #   rpm.changed.each do |package|
    #     p package # print packages that changed
    #   end
    #
    # = TODO:
    #  * add reinstall handling also
    #
    class Rpm
      include BasePackageManager
      # Query for rpm list
      PKG_QUERY = 'rpm -qa --queryformat "%{NAME} %{VERSION}-%{RELEASE}.%{ARCH}\n"'.freeze

      private_constant :PKG_QUERY

      def make_pkg_snapshot
        snapshot = {}
        query_output = `#{PKG_QUERY}`
        query_output.lines.each do |line|
          info = line.split
          snapshot[info[0]] = info[1]
        end

        snapshot
      end
    end
  end
end
