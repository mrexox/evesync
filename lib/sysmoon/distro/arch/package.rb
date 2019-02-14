# TODO: write package-related classes and functions
require 'file-tail'
require 'sysmoon/package'

# Must be called as
# Thread.new { ArchPackageWatcher.new(queue).run }

class ArchPackageWatcher

  ARCH_LOG_FILE = '/var/log/pacman.log'
  private_constant :ARCH_LOG_FILE

  def initialize(queue)
    @queue = queue
  end

  def run
    File.open(ARCH_LOG_FILE) do |log|
      log.extend(File::Tail)
      log.interval = 3
      log.backward(1)
      log.tail do |line|
        if /(?:reinstalled|installed|removed)\s*
           (?<package>\w+)\s*
           \((?<version>[\w\d.-]+)\)/x =~ line
          @queue << Package.new(
            name: package,
            version: version
          )
        end
      end
    end
  end

end
