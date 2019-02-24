require 'json'
require 'sysmoon/ipc_data/package'

# TODO: add custom exceptions for IPCData
module Sysmoon
  module IPCData
    def self.pack(message)
      unless message.respond_to? :to_hash
        err_msg = "Instance #{message} must implement `to_hash'"
        Log.fatal(err_msg)
        raise RuntimeError.new(err_msg)
      end

      hash = message.to_hash
      hash['type'] = message.class.to_s

      hash.to_json
    end

    def self.unpack(message)
      unless message.is_a? String
        raise RuntimeError.new("message #{message} must be of type String")
      end

      begin
        hash = JSON.parse(message)
      rescue JSON::ParseError => e
        Log.fatal("Unable to parse message #{message}")
        raise e
      end

      begin
        cl = Object.const_get hash['type']
      rescue NameError => e
        # FIXME: just sent JSON, this event will be delegated
        # to another daemon (maybe) with fields:
        # redirect_to_port: <port number>
        Log.fatal("Unsupported type #{hash['type']}")
        raise e
      end

      unless cl.respond_to? :from_hash
        err_msg = "Class #{cl} must implement `self.from_hash'"
        Log.fatal(err_msg)
        raise RuntimeError.new(err_msg)
      end

      cl.from_hash hash
    end
  end
end
