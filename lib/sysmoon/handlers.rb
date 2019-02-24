require 'sysmoon/constants'
require 'sysmoon/log'
require 'sysmoon/ipc'
require 'sysmoon/ipc_data'
require 'sysmoon/handlers/file'
require 'sysmoon/handlers/package'

##
# Handles package changes, sent via Package class and queue
#
# Initialized with queue. Usage:
#  Thread.new { LocalMessageHandler.new(queue).run }
#
# Sends messages to sysdatad and available syshands
# TODO: Make anoter daemon\Thread to search for available
# TODO: syshands daemons

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
      ip: IPC_HAND_IP,
      protocol: :tcp
    )
  end

  ##
  # TODO: check if package was really updated (removed or has this version)
  # TODO: add reconnecting to sysdatad after timeout
  # Main loop that handles messages from queue
  # Delivers them to sysdatad and syshands

  def run
    loop do
      message = @queue.pop
      Log.info "#{self.class.name}: #{message}"

      @ipc_datad.deliver(message) do |response|
        if response
          Log.info("Remote response:", response)
          @ipc_hand.deliver(message)
        else
          Log.fatal("Error with data daemon: no response")
        end
      end
    end
  end
end

##
# Remote Message Handler for syshand daemon
# Handlers available:
#  - package updates
#  - file updates
# The code for updating is in particular classes

class RemoteMessageHandler
  def initialize
    @package_handler = RemotePackageHandler.new
    @file_handler    = RemoteFileHandler.new
  end

  def handle(message)
    Log.info "#{self.class.name}: #{message}"

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
  end
end
