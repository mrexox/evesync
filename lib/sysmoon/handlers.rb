require 'sysmoon/log'
require 'sysmoon/ipc'
require 'sysmoon/handlers/file'
require 'sysmoon/handlers/package'

##
# Handles package changes, sent via Package class and queue
#
# Initialized with queue. Usage:
#  Thread.new { PackageHandler.new(queue).run }
class Sysmoon::MessageHandler

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

      json_message = Data::to_json(message)

      @ipc_datad.deliver(json_message) do |response|
        if response
          Log.info("Remote response:", response)
        else
          Log.fatal("Error with data daemon: no response")
          # TODO: add reconnecting after timeout
        end
      end
    end
  end
end

# Handles new events, packages and file updates
class Syshand::MessageHandler
  def initialize
    # init package handler
    @package_handler = Syshand::PackageHandler
    # init file handler
    @file_handler = Syshand::FileHandler
  end

  def handle(message)
    Log.info "#{self.class.name}: #{message}"
    # find out what type of message it is
    # maybe: preformat message
    # delegate message to handler
  end
end
