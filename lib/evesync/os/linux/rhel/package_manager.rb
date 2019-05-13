require 'evesync/log'

# Manages package manager things
# TODO: trigger package_watcher event to update database
module Evesync
  module OS
    module PackageManager
      class << self
        def install(*args)
          return false if exist?(*args)
          yum('install', *args)
          exist?(*args)
        end

        def remove(*args)
          yum('remove', *args)
          !exist?(*args)
        end

        def update(*args)
          yum('update', *args)
          exist?(*args)
        end

        def downgrade(*args)
          yum('downgrade', *args)
          exist?(*args)
        end

        def yum(cmd, name, version)
          Log.debug("Yum command: '#{cmd}' on #{name}-#{version}")
          system("yum --assumeyes #{cmd} #{name}-#{version}")
        end

        def exist?(name, version)
          Log.debug("Yum checking if exists: #{name}-#{version}")
          system("rpm -q #{name}-#{version} >/dev/null 2>&1")
        end
      end
    end
  end
end
