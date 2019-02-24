require 'sysmoon/log'
require 'sysmoon/ipc'
require 'sysmoon/ipc_data'
require 'sysmoon/handlers/file'
require 'sysmoon/handlers/package'

##
# Handles package changes, sent via Package class and queue
#
# Initialized with queue. Usage:
#  Thread.new { PackageHandler.new(queue).run }
class LocalMessageHandler

  def initialize(queue)
    @queue = queue

    @ipc_datad = IPC.new(
      side: :client,
      connect_to: :datad,
      protocol: :tcp
    )

    @ipc_hand = IPC.new(
      side: :client,
      connect_to: :hand,
      ip: 'localhost',
      protocol: :tcp
    )
  end

  def run
    loop do
      message = @queue.pop
      # TODO: check if package was really updated (removed or has this version)
      Log.info "#{self.class.name}: #{message}"

      # FIXME: handle bad messages exceptions

      @ipc_datad.deliver(message) do |response|
        if response
          Log.info("Remote response:", response)
          @ipc_hand.deliver(message)
        else
          Log.fatal("Error with data daemon: no response")
          # TODO: add reconnecting after timeout
        end
      end
    end
  end
end

# Handles new events, packages and file updates
class RemoteMessageHandler
  def initialize
    # init package handler
    @package_handler = RemotePackageHandler.new
    # init file handler
    @file_handler = RemoteFileHandler.new
  end

  def handle(message)
    Log.info "#{self.class.name}: #{message}"
    # TODO:
    if message.is_a? Package
      Log.debug('Package handler')
      @package_handler.handle(message)
    elsif message.is_a? File
      Log.debug('File handler')
      @file_handler.handle(message)
    else
      Log.debug('Unknown handler')
      # TODO: delegate to another daemon
    end
    # find out what type of message it is
    # maybe: preformat message
    # delegate message to handler
  end
end
