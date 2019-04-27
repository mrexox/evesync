require 'evesync/log'
require 'json'

module Evesync
  module IPC
    module Data
      # The class, that includes it must implement method
      # *initialize(params)*
      # This is a MUST BE requirement
      #
      module Hashable
        def to_hash
          hash = {}
          instance_variables.each do |var|
            value = instance_variable_get(var)

            if value.respond_to? :to_hash
              # FIXME: if it wasn't implemented it'll be an error
              # for a complex type
              hash[var] = value.to_hash
              hash[var]['type'] = value.class.to_s
            else
              hash[var] = value
            end
            hash['type'] = self.class.to_s
          end
          Log.debug("IPC Data message hash created: #{hash}")
          hash
        end
      end

      module Unhashable
        def from_hash(hash)
          Log.debug("IPC Data message hash parsing: #{hash}")
          params = {}
          hash.each do |key, value|
            next unless key =~ /^@/

            if value.is_a? Hash
              # FIXME: code dumplication ipc_data.rb:31
              begin
                cl = Object.const_get value['type']
              rescue NameError => e
                Log.fatal("IPC Data Unsupported type: #{hash['type']}")
                raise e
              end

              unless cl.respond_to? :from_hash
                err_msg = "IPC Data ERROR Class #{cl} must implement `self.from_hash'"
                Log.fatal(err_msg)
                raise err_msg
              end

              complex_value = cl.from_hash value
              params[key.sub('@', '').to_sym] = complex_value
            else
              params[key.sub('@', '').to_sym] = value
            end
          end

          begin
            # If the `type' is imported it will be used
            cl = Object.const_get hash['type']
          rescue TypeError, NameError
            # Or the base class will be the type
            cl = self
          end

          cl.new(params)
        end
      end
    end
  end
end
