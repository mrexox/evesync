module Evesync
  module OS
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
          Log.debug("Apt-get command: '#{cmd}' on #{name}=#{version}")
          system("apt-get --assume-yes #{cmd} #{name}=#{version}")
        end

        def exist?(name, version)
          Log.debug("Dpkg checking if exists: #{name}-#{version}")
          `dpkg-query -l #{name}`
          $CHILD_STATUS == 0
        end
      end
    end
  end
end
