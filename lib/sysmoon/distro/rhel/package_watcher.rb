require_relative './rpm'
require 'sysmoon/log'

module Sysmoon
  class RhelPackageWatcher

    attr_reader :thread

    def initialize(queue)
      @queue = queue
      @rpm_packages = Rpm.new
      @ignore = []
      @thread = nil
    end

    def run
      @thread = Thread.new(@ignore) do |ignore_packages|
        loop {
          sleep 10 # FIXME: don't use magic numbers
          @rpm_packages.changes.each do |pkg|
            ignore_packages.pop # TODO: add a check if pkg is ignored
            @queue << pkg
            Log.debug pkg
          end
        }
      end

      @thread
    end
  end
end
