require 'evesync/config'

module Evesync
  #
  # Constants and helpful functions for Evesync::IPC module.
  #
  module IPC
    $SAFE = 1 # 'no eval' rule

    private

    # Checks if params have the provided keys
    #
    # [*Raise*] RuntimeError if params don't include on of the
    #             keys
    def check_params_provided(params, keys)
      keys.each do |param|
        raise ":#{param} missed" unless
          params.key?(param)
      end
    end

    # Maps symbols like :evemond, :evehand to appropriate
    # port number.
    #
    # [*Return*] Port number, if it's in (49152..65535)
    #             or one of daemons' name
    def get_port(params)
      port = params[:port]
      if port.is_a? Symbol
        Config[port.to_s]['port']
      else
        port_i = port.to_i
        unless (port_i < 65_535) && (port_i > 49_152)
          raise RuntimeError.call('Port MUST be in (49152..65535)')
        end

        port
      end
    end
  end
end
