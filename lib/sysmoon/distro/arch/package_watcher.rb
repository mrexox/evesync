require 'file-tail'
require 'sysmoon/log'
require 'sysmoon/ipc/data/package'

module Sysmoon

  ##
  # Watcher for package changes for Arch Linux
  #
  # Usage:
  #  Thread.new { ArchIPC::Data::PackageWatcher.new(queue).run }

  class ArchPackageWatcher

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
      @ignore = []
      @thread = nil
      Log.debug('Arch Package watcher initialized')
    end

    def ignore(package)
      @ignore << package
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
            # TODO: write a check if that name and version are ignored
            if m and process_or_ignore(m[:package], m[:version])
              pkg = IPC::Data::Package.new(
                name: m[:package],
                version: m[:version],
                command: m[:command]
              )
              @queue << pkg
              Log.debug pkg
            end
          end
        end
      end

      @thread
    end

    private

    def process_or_ignore(name, version)
      index = -1
      Log.debug("Ignore array: #{@ignore}")

      @ignore.each_with_index do |pkg, i|
        if pkg.name == name and pkg.version == version
          index = i
          break
        end
      end

      if index != -1
        Log.debug("Package #{name}-#{version} is ignored")
        @ignore.delete_at(index)
        return nil
      end

      true
    end
  end
end
