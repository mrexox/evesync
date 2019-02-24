# Manages package manager things
module Sysmoon
  module RhelPackageManager
    class << self
      def install(*args)
        yum('install', *args)
      end

      def remove(*args)
        yum('remove', *args)
      end

      def update(*args)
        yum('update', *args)
      end

      def downgrade(*args)
        yum('downgrade', *args)
      end

      def yum(cmd, name, version)
        `yum --assumeyes #{cmd} #{name}-#{version}`
      end
    end
  end
end
