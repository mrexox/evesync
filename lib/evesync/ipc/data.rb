require 'drb/drb'

module Evesync


  module IPCData
    # TODO: add custom exceptions for IPCData


    def self.pack(message)
      unless message.respond_to? :to_hash
        err_msg = "IPC ERROR Instance #{message} must implement `to_hash'"
        Log.fatal(err_msg)
        raise err_msg
      end

      hash = message.to_hash

      hash.to_json
    end

    def self.unpack(message)
      unless message.is_a? String
        raise "IPC ERROR message #{message} must be of type String"
      end

      begin
        hash = JSON.parse(message)
      rescue JSON::ParseError => e
        Log.fatal("IPC ERROR Unable to parse message #{message}")
        raise e
      end

      begin
        Log.debug("IPC Accepted basic hash #{hash}")
        cl = Object.const_get hash['type']
      rescue NameError => e
        # FIXME: just sent JSON, this event will be delegated
        # to another daemon (maybe) with fields:
        # redirect_to_port: <port number>
        Log.fatal("Unsupported basic type #{hash['type']}")
        raise e
      end

      unless cl.respond_to? :from_hash
        err_msg = "IPC ERROR Class #{cl} must implement `self.from_hash'"
        Log.fatal(err_msg)
        raise err_msg
      end

      cl.from_hash hash
    end
  end
end
