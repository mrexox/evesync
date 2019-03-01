require 'drb/drb'
require 'sysmoon/log'
require 'sysmoon/ipc/ipc'

module  Sysmoon
  module IPC
    class Client
      def initialize(params)
        check_params_provided(params, [:port])
        ip = params[:ip] || 'localhost' # FIXME: check ip
        @uri = "druby://#{ip}:#{port}"
        # DRb.start_service # to handle callbacks
      end

      # TODO: add callbacks
      def method_missing(method, *args, &block)
        # FIXME: don't send +start+ and +stop+ and +initialize+
        service = DRbObject.new_with_uri(@uri)
        service.send(method, *args, &block)
      end
    end
  end
end
