require 'sysmoon/log'
require 'sysmoon/ipc'

##
# Handles package changes, sent via Package class and queue
#
# Initialized with queue. Usage:
#  Thread.new { PackageHandler.new(queue).run }
class PackageHandler

  def initialize(queue)
    @queue = queue
    @ipc = IPC.new(
      side: :client,
      host: :localhost,
      port: 5432, # FIXME: read from config
      protocol: :tcp
    )
  end

  def run
    loop do
      package = @queue.pop
      # TODO: check if package was really updated (removed or has this version)
      Log.info "Package Handler: #{package}"

      @ipc.pass(package) do |response, chan|
        # TODO: send updates to sysdatad
      end
    end
  end
end
