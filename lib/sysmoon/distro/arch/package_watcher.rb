require 'file-tail'
require 'sysmoon/log'
require 'sysmoon/config'
require 'sysmoon/ipc/data/package'

module Sysmoon
  module Distro
    # = Synopsis
    # Watcher for package changes for Arch Linux
    #
    # = Example
    #  Thread.new { IPC::Data::PackageWatcher.new(queue).run }
    class PackageWatcher
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

      def run
        Log.debug('Arch Package watcher started')
        Thread.new do
          File.open(ARCH_LOG_FILE) do |log|
            log.extend(File::Tail)
            log.interval = Config[:sysmoond]['watch-interval']
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
    end
  end
end
