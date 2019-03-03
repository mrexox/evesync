require 'sysmoon/log'

# Manages package manager things
module Sysmoon
  module RhelPackageManager
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
        system("rpm -q #{name}-#{version}")
      end
    end
  end
end
