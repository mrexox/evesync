##
# This package is for inotify communication
# The file can be suddenly IN_IGNORED
# So the method to renew the inotify on this file must present

module Inotify
  # Files
  
  def on_file_modified(props)
  end

  def on_file_created(props)
  end

  def on_file_deleted(props)
  end

  # Dirs
  
  def on_dir_created(props)
  end

  def on_dir_modified(props)
  end

  def on_dir_deleted(props)
  end
end
