require 'drb/drb'
require 'evesync/log'
require 'evesync/ipc/ipc'

module  Evesync
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
        Log.debug("RPC Client calling '#{method}' on #{@uri}")
        # FIXME: don't send +start+ and +stop+ and +initialize+
        begin
          service = DRbObject.new_with_uri(@uri)
          res = service.send(method, *args, &block)
          Log.debug("RPC Client method '#{method}' handled on #{@uri}")
          res
        rescue StandardError
          Log.warn("RPC Client ERROR: no connection")
          nil
        end
      end
    end
  end
end
