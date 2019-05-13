require 'file-tail'
require 'evesync/log'
require 'evesync/config'
require 'evesync/ipc/data/package'
require 'evesync/watcher/interface'

module Evesync
  module OS

    # Watcher for package changes for Arch Linux
    #
    # = Example
    #  Thread.new { IPC::Data::PackageWatcher.new(queue).run }
    class PackageWatcher < Watcher::Interface
      ARCH_LOG_FILE = '/var/log/pacman.log'.freeze
      PKG_REGEXP =
        /(?<command>reinstalled|installed|removed)
    \s*
    (?<package>\w+)
    \s*
    \(   (?<version>[\w\d.-]+)   \)
    /x.freeze

      private_constant :ARCH_LOG_FILE, :PKG_REGEXP

      def initialize(queue)
        @queue = queue
        Log.debug('Arch Package watcher initialized')
      end

      def start
        Log.debug('Arch Package watcher started')
        @thr = Thread.new do
          File.open(ARCH_LOG_FILE) do |log|
            log.extend(File::Tail)
            log.interval = Config[:evemond]['watch-interval']
            log.backward(1)
            log.tail do |line|
              m = line.match(PKG_REGEXP)
              next unless m

              pkg = IPC::Data::Package.new(
                name: m[:package],
                version: m[:version],
                command: m[:command]
              )
              @queue << pkg
              Log.debug 'Arch package watcher enqued:', pkg
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
