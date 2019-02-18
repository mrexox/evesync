# Manages package manager things
module RhelPackageManager
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

  private

  def yum(cmd, name, version)
    `yum --assumeyes #{cmd} #{name}-#{version}`
  end
end
