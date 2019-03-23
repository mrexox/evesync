require 'sysmoon/log'

# Manages package manager things
# TODO: trigger package_watcher event to update database
module Sysmoon
  module Distro
    module PackageManager
      class << self
        def install(*args)
          yum('install', *args)
          exist?(*args)
        end

        def remove(*args)
          yum('remove', *args)
          not exist?(*args)
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
          Log.debug("Calling '#{cmd}' on #{name}-#{version}")
          system("yum --assumeyes #{cmd} #{name}-#{version}")
        end

        def exist?(name, version)
          Log.debug("Checking if #{name}-#{version} exists")
          %x(rpm -q #{name}-#{version})
          $? == 0
        end
      end
    end
  end
end
