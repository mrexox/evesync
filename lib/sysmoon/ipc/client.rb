module  Sysmoon
  module IPC
    class Client
      IP_regex = Regexp.new('(:?<ip>\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}):(:?<port>\d{1,5})')
      def initialize(params)

        unless params[:connect_to]
          raise RuntimeError.new("param :connect_to missing")
        end

        case params[:connect_to]
        when :datad
          @ip = 'localhost'
          @port = SYSDATAD_PORT  # FIXME: read from config
        when :hand
          @ip = params[:ip] || 'localhost'
          @port = SYSHAND_PORT
        when :moond
          @ip = params[:ip] || 'localhost'
          @port = SYSMOOND_PORT
        else
          m = IP_regex.match(params[:connect_to])
          unless m
            raise RuntimeError.new("param :connect_to format is not ip:port")
          end
          @ip = m[:ip]
          @port = m[:port]
        end

        # TODO: using this var change connections and deliver methods
        @protocol = params[:protocol]
      end


      # A blocking method for Client side
      # If client, returns an answer (blocking)
      # If server, returns FIXME: nothing? (blocking?)
      # Accepts a block. If given executes it with data recieved
      def deliver(data, ip: @ip)
        unless ip
          Log.debug("Given empty ip: #{ip}")
          return
        end

        socket = TCPSocket.new(ip, @port)

        socket.puts(IPCData::pack(data))

        Log.debug("Message sent to #{ip}:#{@port}")

        recieved = socket.gets

        socket.close

        if block_given? and recieved
          recieved.chomp!
          yield recieved
        end

        recieved
      end
    end
  end
end
