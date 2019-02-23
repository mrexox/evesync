require 'sysmoon/log'
require 'sysmoon/ipc'

##
# Handles package changes, sent via Package class and queue
#
# Initialized with queue. Usage:
#  Thread.new { PackageHandler.new(queue).run }
class MessageHandler

  def initialize(queue)
    @queue = queue
    @ipc_datad = IPC.new(
      side: :client,
      connect_to: :datad,
      protocol: :tcp
    )
  end

  def run
    loop do
      message = @queue.pop
      # TODO: check if package was really updated (removed or has this version)
      Log.info "#{self.class.name}: #{message}"

      @ipc_datad.deliver(message) do |response|
        if response
          Log.info("Remote response:", response)
        else
          Log.fatal("Error with data daemon: no response")
        end
      end
    end
  end
end
