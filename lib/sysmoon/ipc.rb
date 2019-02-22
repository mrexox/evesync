require 'socket'

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
      ip = 'localhost'
      port = 54321  # FIXME: read from config
    else
      m = IP_regex.match(params[:connect_to])
      unless m
        raise RuntimeError.new("param :connect_to format is not ip:port")
      end
      ip = m[:ip]
      port = m[:port]
    end

    # TODO: using this var change connections and deliver methods
    @protocol = params[:protocol]
    @socket = TCPSocket.new(ip, port)
  end


  # A blocking method for Client side
  # If client, returns an answer (blocking)
  # If server, returns FIXME: nothing? (blocking?)
  # Accepts a block. If given executes it with data recieved
  def deliver(data)
    @socket.write(data.to_s)
  end
end

class IPC::Server
  def initialize(params)

    case params[:port]
    when :datad
      port = '54321' # FIXME: read from config
    else
      # parse port or sent error
    end

    # TODO: using this var change connections and deliver methods
    @protocol = params[:protocol]
    @socket = TCPServer.new port
  end

  # A blocking method for Server side
  # Recieves a message from the client and executes a block
  # Example:
  #   ipc.recv do |data, channel|
  #     puts data
  #     channel.put 'ok'
  #   end
  def on_recieve(&block)
  end
end
