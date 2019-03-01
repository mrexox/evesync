require 'sysmoon/distro'

module Sysmoon
  module Watcher
    class Package
      def initialize
        @watcher = Distro::PackageWacther.new
      end

      def run
        @watcher.run
      end
    end
  end
end
