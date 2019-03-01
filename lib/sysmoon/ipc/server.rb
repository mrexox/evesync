module Sysmoon
  module IPC
    class Server
      def initialize(params)
        case params[:port]
        when :datad
          port = SYSDATAD_PORT # FIXME: read from config
        when :hand
          port = SYSHAND_PORT
        when :moond
          port = SYSMOOND_PORT
        else
          if port !~ /^\d{1,5}$/
            raise RuntimeError.new("param: port is not 5 digit")
          end
          port = params[:port]
        end

        # TODO: using this var change connections and deliver methods
        @protocol = params[:protocol]
        @socket = TCPServer.new port
      end

      # A blocking method for Server side
      # Recieves a message from the client and executes a block
      # Example:
      #   ipc.on_recieve do |data, channel|
      #     puts data
      #     channel.put 'ok'
      #   end
      #   thr = ipc.start
      #   thr.join
      def on_recieve(&block)
        @block = block
      end

      def start
        Thread.new(@socket, @block) do |socket, block|
          loop do
            client = socket.accept

            Log.debug('Accepted request. Started handle thread.')

            Thread.new(client, block) { |cl, bl|
              message = cl.gets
              unless message then cl.close end
              message.chomp!
              unpacked_message = IPCData::unpack(message)
              Log.debug("Unpacked: #{unpacked_message}")
              bl.call(unpacked_message, client)
              cl.close
            }.join

            Log.debug('Done with handle thread.')
          end
        end
      end

      def stop
        @socket.close
      end
    end
  end
end
