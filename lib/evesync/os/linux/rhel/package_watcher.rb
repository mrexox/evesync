require_relative './rpm'
require 'evesync/log'
require 'evesync/watcher/interface'

module Evesync
  module OS
    class PackageWatcher < Watcher::Interface
      def initialize(queue)
        @queue = queue
        @rpm_packages = Rpm.new
        Log.debug('Rhel Package watcher initialized')
      end

      def start
        Log.debug('Rhel Package watcher started')
        @thr = Thread.new do
          loop do
            sleep 10 # FIXME: don't use magic numbers
            @rpm_packages.changes.each do |pkg|
              @queue << pkg
              Log.debug 'Rhel Package watcher enqued:', pkg
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
