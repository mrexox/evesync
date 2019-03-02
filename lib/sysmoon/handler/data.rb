require 'sysmoon/ipc/data/package'
require 'sysmoon/ipc/data/file'
require 'sysmoon/ipc/data/ignore'

module Sysmoon
  module Handler

    # = Synopsis:
    #
    # *Data* class is a handler for *sysdatad* daemon
    # implements at least one method: +save+. Allows
    # Local +sysmoond+ save messages about changes
    #
    # Messages should be serializable (JSON)
    #
    # = TODO:
    #  * Think about how it can be widened
    #
    class Data
      def initialize
      end

      def save(message)
        Log.debug("Data handler called: #{message}")
        'Fine'
      end
    end
  end
end
