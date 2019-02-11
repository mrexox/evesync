# TODO write package-related classes and functions
require 'file-tail'

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
        if /(reinstall|install|remove)/.match(line) then
          @queue << line.freeze
        end
      end
    end
  end

end
