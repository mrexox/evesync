module Sysmoon
  module Distro
    # FIXME: pacman downgrading requires full url path
    module PackageManager
      class << self
        def install(*args)
          pacman('-Sy', *args)
        end

        def remove(*args)
          pacman('-R', *args)
        end

        # FIXME: update and downgrade specific version is not fine
        def update(*args)
          pacman('-U', *args)
        end

        def downgrade(*args)
          pacman('-U', *args)
        end

        def pacman(cmd, name, _version)
          `pacman #{cmd} #{name}` # FIXME: do smth with version
        end
      end
    end
  end
end
