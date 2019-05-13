require 'evesync/log'
require 'evesync/os'

module Evesync
  class Handler
    class Package
      def handle(message)
        Log.debug('Handler Package handling started...')

        args = [message.name, message.version]

        case message.command
        when /install/
          OS::PackageManager.install(*args)
        when /remove/
          OS::PackageManager.remove(*args)
        when /update/
          OS::PackageManager.update(*args)
        when /downgrade/
          OS::PackageManager.downgrade(*args)
        else
          Log.warn("Handler Package command unknown: #{message.command}")
          return false
        end
        Log.debug('Handler Package handling done!')
        true
      end
    end
  end
end
