require 'sysmoon/log'
require 'sysmoon/distro'

module Sysmoon
  class RemotePackageHandler
    def handle(message)
      case message.command
      when /install/
        PackageManager::install(message.name, message.version)
      when /remove/
        PackageManager::remove(message.name, message.version)
      when /update/
        PackageManager::update(message.name, message.version)
      when /downgrade/
        PackageManager::downgrade(message.name, message.version)
      else
        Log.warn("Unknown command #{message.command}")
      end
    end
  end
end
