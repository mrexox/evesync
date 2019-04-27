require 'evesync/log'
require_relative './dpkg'

module Evesync
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
          loop do
            sleep 10
            @dpkg.changes.each do |pkg|
              @queue << pkg
              Log.debug 'Debian Package watcher enqued:', pkg
            end
          end
        end
      end
    end
  end
end
