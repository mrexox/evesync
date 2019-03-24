require 'sysmoon/log'
require_relative './dpkg'

module Sysmoon
  module Distro
    class PackageWatcher
      def initialize(queue)
        @queue = queue
        @dpkg = Dpkg.new
        Log.debug('Debian Package watcher initialized')
      end

      def run
        Log.debug('Debian Package watcher started')
        Thread.new do
          loop {
            sleep 10
            @dpkg.changes.each do |pkg|
              @queue << pkg
              Log.debug pkg
            end
          }
        end
      end
    end
  end
end
