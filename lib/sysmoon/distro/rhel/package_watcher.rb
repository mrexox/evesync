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

    def ignore(package)
      Log.debug('Checking if package would be ignored')
      if package.is_a? IPC::Data::Package
        Log.debug('Package is ignored')
        @ignore << package
      else
        Log.debug('Package is not an IPC::Data::Package instance')
      end
    end

    def unignore(package)
      index = find_ignore_index(package)
      @ignore.delete_at(index)
    end

    private

    def process_or_ignore(package)
      Log.debug("Ignore aray: #{@ignore}")
      index = find_ignore_index(package)

      if index != -1
        Log.debug("Igored package #{package}")
        @ignore.delete_at(index)
        return nil
      end

      true
    end

    def find_ignore_index(package)
      @ignore.each_with_index do |ignpkg, i|
        if ignpkg.name == package.name and ignpkg.version == package.version and ignpkg.command == package.command
          return i
        end
      end
      -1
    end
  end
end
