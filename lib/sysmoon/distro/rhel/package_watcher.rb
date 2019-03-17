require_relative './rpm'
require 'sysmoon/log'
require 'sysmoon/ipc/data/package'

module Sysmoon
  class RhelPackageWatcher

    attr_reader :thread # FIXME: remove

    def initialize(queue)
      @queue = queue
      @rpm_packages = Rpm.new
      @ignore = []
      @thread = nil
      Log.debug('Rhel package watcher initialized')
    end

    def run
      Log.debug('Rhel package watcher run')
      @thread = Thread.new do
        loop {
          sleep 10 # FIXME: don't use magic numbers
          @rpm_packages.changes.each do |pkg|
            if process_or_ignore(pkg)
              @queue << pkg
              Log.debug pkg
            end
          end
        }
      end

      @thread
    end

  end
end
