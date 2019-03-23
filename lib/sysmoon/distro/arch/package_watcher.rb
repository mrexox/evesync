require 'file-tail'
require 'sysmoon/log'
require 'sysmoon/ipc/data/package'

module Sysmoon
  module Distro
  ##
  # Watcher for package changes for Arch Linux
  #
  # Usage:
  #  Thread.new { ArchIPC::Data::PackageWatcher.new(queue).run }

  class PackageWatcher

    ARCH_LOG_FILE = '/var/log/pacman.log'
    PKG_REGEXP =
      /(?<command>reinstalled|installed|removed)
    \s*
    (?<package>\w+)
    \s*
    \(   (?<version>[\w\d.-]+)   \)
    /x

    private_constant :ARCH_LOG_FILE, :PKG_REGEXP

    attr_reader :thread # FIXME: remove

    def initialize(queue)
      @queue = queue
      @thread = nil
      Log.debug('Arch Package watcher initialized')
    end


    def run
      Log.debug('Arch Package watcher started')
      @thread = Thread.new do
        File.open(ARCH_LOG_FILE) do |log|
          log.extend(File::Tail)
          log.interval = 3
          log.backward(1)
          log.tail do |line|
            m = line.match(PKG_REGEXP)
            pkg = IPC::Data::Package.new(
              name: m[:package],
              version: m[:version],
              command: m[:command]
            )
            @queue << pkg
            Log.debug pkg
          end
        end
      @thread
    end
  end
end
