require 'evesync/log'
require 'evesync/watcher/interface'
require_relative './dpkg'

module Evesync
  module OS
    class PackageWatcher < Watcher::Interface
      def initialize(queue)
        @queue = queue
        @dpkg = Dpkg.new
        Log.debug('Debian Package watcher initialized')
      end

      def start
        Log.debug('Debian Package watcher started')
        @thr = Thread.new do
          loop do
            sleep 10
            @dpkg.changes.each do |pkg|
              @queue << pkg
              Log.debug 'Debian Package watcher enqued:', pkg
            end
          end
        end
      end

      def stop
        @thr.exit
      end
    end
  end
end
