require 'sysmoon/constants'

module Sysmoon

  #
  # Constants and helpful functions for Sysmoon::IPC module.
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
        raise RuntimeError.new(":#{param} missed") unless
          params.key?(param)
      end
    end

    # Maps symbols like :sysmoond, :syshand to appropriate
    # port number.
    #
    # [*Return*] Port number, if it's in (49152..65535)
    #             or one of daemons' name
    def get_port(params)
      port = params[:port]
      p = case port
          when :sysmoond then Constants::SYSMOOND_PORT
          when :sysdatad then Constants::SYSDATAD_PORT
          when :syshand then Constants::SYSHAND_PORT
          else
            port_i = port.to_i
            unless port_i < 65535 and port_i > 49152
              raise RuntimeError.("Port MUST be in (49152..65535)")
            end
            port
          end
      p
    end
  end
end
