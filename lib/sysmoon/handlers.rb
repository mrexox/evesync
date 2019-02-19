require 'sysmoon/log'

##
# Handles package changes, sent via Package class and queue
#
# Initialized with queue. Usage:
#  Thread.new { PackageHandler.new(queue).run }
class PackageHandler

  def initialize(queue)
    @queue = queue
  end

  def run
    loop do
      package = @queue.pop
      # TODO: send updates to sysdatad
      Log.info "Package Handler: #{package}"
    end
  end
end
