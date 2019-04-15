require 'sysmoon/log'
require 'sysmoon/distro'

module Sysmoon
  class Handler
    class Package
      def handle(message)
        Log.debug("Handling #{message}")

        args = [message.name, message.version]

        case message.command
        when /install/
          Distro::PackageManager.install(*args)
        when /remove/
          Distro::PackageManager.remove(*args)
        when /update/
          Distro::PackageManager.update(*args)
        when /downgrade/
          Distro::PackageManager.downgrade(*args)
        else
          Log.warn("Unknown command #{message.command}")
          return false
        end
      end
    end
  end
end
