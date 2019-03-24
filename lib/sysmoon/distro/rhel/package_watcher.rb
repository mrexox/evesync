require_relative './rpm'
require 'sysmoon/log'

module Sysmoon
  module Distro
    class PackageWatcher

      def initialize(queue)
        @queue = queue
        @rpm_packages = Rpm.new
        Log.debug('Rhel package watcher initialized')
      end

      def run
        Log.debug('Rhel package watcher run')
        Thread.new do
          loop {
            sleep 10 # FIXME: don't use magic numbers
            @rpm_packages.changes.each do |pkg|
              @queue << pkg
              Log.debug pkg
            end
          }
        end
      end
    end
  end
end
