require 'socket'
require 'sysmoon/constants'
require 'sysmoon/ipc_data'

module Sysmoon

  ##
  # IPC for sysmoon (that can be changed in future)
  # Using socket-based approach
  # TCP sockets are the default

  class IPC
    def initialize(params)
      # Checking params
      unless [:tcp, :udp].include?(params[:protocol])
        raise RuntimeError.new("Protocol must be one of [tcp,udp]")
      end

      case params[:side]
      when :client then @socket = IPC::Client.new(params)
      when :server then @socket = IPC::Server.new(params)
      else
        raise RuntimeError.new(
                "Unexpected param params[:side]=#{params[:side]}")
      end
    end

    def method_missing(method, *args, &block)
      @socket.send(method, *args, &block)
    end

  end

  class IPC::Client
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

      recieved = socket.gets.chomp

      socket.close

      if block_given?
        yield recieved
      end

      recieved
    end
  end

  class IPC::Server
    def initialize(params)
      case params[:port]
      when :datad
        port = SYSDATAD_PORT # FIXME: read from config
      when :hand
        port = SYSHAND_PORT
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
      Thread.new do
        loop do
          client = @socket.accept
          Log.debug('Accepted request. Started handle thread.')
          Thread.new(client, @block) { |cl, block|
            message = cl.gets.chomp
            unpacked_message = IPCData::unpack(message)
            Log.debug("Unpacked: #{unpacked_message}")
            block.call(unpacked_message, client)
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
