require 'drb/drb'
require 'sysmoon/log'
require 'sysmoon/ipc/ipc'

module  Sysmoon
  module IPC
    class Client
      include IPC
      def initialize(params)
        check_params_provided(params, [:port])
        port = get_port(params)
        ip = params[:ip] || 'localhost' # FIXME: check ip
        @uri = "druby://#{ip}:#{port}"
        # DRb.start_service # to handle callbacks
      end

      # TODO: add callbacks
      def method_missing(method, *args, &block)
        Log.debug("Sending method #{method} to #{@uri}")
        # FIXME: don't send +start+ and +stop+ and +initialize+
        service = DRbObject.new_with_uri(@uri)
        service.send(method, *args, &block)
        Log.debug("Method #{method} was handled by #{@uri}")
      end
    end
  end
end
