##
# IPC for sysmoon (that can be changed in future)
# Using socket-based approach
# TCP sockets are the default
class IPC
  def initialize(params)
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
  def initialize(params)
  end


  # A blocking method for Client side
  # If client, returns an answer (blocking)
  # If server, returns FIXME: nothing? (blocking?)
  # Accepts a block. If given executes it with data recieved
  def pass(data)
  end
end

class IPC::Server
  def initialize(params)
  end

  # A blocking method for Server side
  # Recieves a message from the client and executes a block
  # Example:
  #   ipc.recv do |data, channel|
  #     puts data
  #     channel.put 'ok'
  #   end
  def recv(&block)
  end
end
