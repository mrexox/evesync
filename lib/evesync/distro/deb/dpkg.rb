require 'hashdiff'
require 'evesync/log'
require 'evesync/distro/base_package_manager'

module Evesync
  module Distro
    class Dpkg
      include BasePackageManager

      PKG_QUERY = 'dpkg-query -l'.freeze

      private_constant :PKG_QUERY

      # Snapshot is a hash where key is a package name
      # and value - it's version.
      # This function returns a snapshot of a system
      # package status for a moment
      def make_pkg_snapshot
        snapshot = {}
        query_output = `#{PKG_QUERY}`
        query_output.lines.each do |line|
          info = line.split
          snapshot[info[1]] = info[2]
        end

        snapshot
      end
    end
  end
end
