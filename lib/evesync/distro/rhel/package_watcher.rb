require_relative './rpm'
require 'evesync/log'

module Evesync
  module Distro
    class PackageWatcher
      def initialize(queue)
        @queue = queue
        @rpm_packages = Rpm.new
        Log.debug('Rhel Package watcher initialized')
      end

      def run
        Log.debug('Rhel Package watcher started')
        Thread.new do
          loop do
            sleep 10 # FIXME: don't use magic numbers
            @rpm_packages.changes.each do |pkg|
              @queue << pkg
              Log.debug 'Rhel Package watcher enqued:', pkg
            end
          end
        end
      end
    end
  end
end
