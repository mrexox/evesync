module Sysmoon
  module Distro
    module PackageManager
      class << self
        def install(*args)
          apt_get('install', *args)
          exist?(*args)
        end

        def remove(*args)
          apt_get('remove', *args)
          !exist?(*args)
        end

        def update(*args)
          apt_get('upgrade', *args)
          exist?(*args)
        end

        def downgrade(*args)
          apt_get('install', *args)
          exist?(*args)
        end

        def apt_get(cmd, name, version)
          Log.debug("Calling '#{cmd}' on #{name}=#{version}")
          system("apt-get --assume-yes #{cmd} #{name}=#{version}")
        end

        def exist?(name, version)
          Log.debug("Checking if #{name}-#{version} exists")
          `dpkg-query -l #{name}`
          $CHILD_STATUS == 0
        end
      end
    end
  end
end
