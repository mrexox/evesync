require 'drb/drb'
require 'sysmoon/log'
require 'sysmoon/ipc/ipc'

module  Sysmoon
  module IPC
    class Client
      include IPC

      attr_reader :ip, :uri

      def initialize(params)
        check_params_provided(params, [:port])
        port = get_port(params)
        @ip = params[:ip] || 'localhost' # TODO: check ip
        @uri = "druby://#{@ip}:#{port}"
        # to remote calls for unmarshallable objects
        DRb.start_service
      end

      # TODO: add callbacks
      def method_missing(method, *args, &block)
        Log.debug("Sending method #{method} to #{@uri}")
        # FIXME: don't send +start+ and +stop+ and +initialize+
        begin
          service = DRbObject.new_with_uri(@uri)
          service.send(method, *args, &block)
          Log.debug("Method #{method} was handled by #{@uri}")
        rescue StandardError
          Log.warn("Couldn't establish connection")
        end
      end
    end
  end
end
