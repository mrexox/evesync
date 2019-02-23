require 'file-tail'
require 'sysmoon/data/package'

##
# Watcher for package changes for Arch Linux
#
# Usage:
#  Thread.new { ArchPackageWatcher.new(queue).run }
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

  def initialize(queue)
    @queue = queue
  end

  def run
    File.open(ARCH_LOG_FILE) do |log|
      log.extend(File::Tail)
      log.interval = 3
      log.backward(1)
      log.tail do |line|
        m = line.match(PKG_REGEXP)
        if m
          pkg = Data::Package.new(
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

end
