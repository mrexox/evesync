require 'cod'

##
# IPC for sysmoon (that can be changed in future)
# Using socket-based approach
# TCP sockets are the default
module IPC
  def new(params)
    case params[:side]
    when :client then IPC::Client.new(params)
    when :server then IPC::Server.new(params)
    else
      raise RuntimeError.new(
              "Unexpected param params[:side]=#{params[:side]}")
  end
end

class IPC::Client
  def initialize(params)
  end


  # A blocking method for Client side
  # If client, returns an answer (blocking)
  # If server, ereturns FIXME: nothing? (blocking?)
  # Accepts a block. If given executes it with data recieved
  def send(data)
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
