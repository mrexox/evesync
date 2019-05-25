require 'drb/drb'
require 'evesync/log'
require 'evesync/ipc/ipc'

module Evesync
  module IPC

    ##
    # Server is a DRb object, using +:port+ and +:proxy+
    # object to handle requests.
    #
    # = Params
    #
    # [*:proxy*] all methods go to this object
    # [*:port*]  defines which port which port connect to
    #
    # = Example:
    #
    #   # Setup the server
    #   server = Evesync::IPC::Server(
    #     :port => '8089',
    #     :proxy => SomeHandler.new
    #   )
    #   ...
    #   server.start # now it starts recieving requests
    #   ...
    #   server.stop # main thread exits
    #
    # TODO:
    #   * Handle blocks

    class Server
      include IPC

      attr_reader :uri

      def initialize(params)
        check_params_provided(params, %i[port proxy])
        port = get_port params
        ip = params[:ip] || 'localhost'
        @uri = "druby://#{ip}:#{port}"
        @proxy = params[:proxy]
      end

      def start
        DRb.start_service(@uri, @proxy)
        self
      end

      def stop
        DRb.thread.exit
        self
      end
    end
  end
end
