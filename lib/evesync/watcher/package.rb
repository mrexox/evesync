require 'evesync/os/linux'

module Evesync
  class Watcher
    # Package class is a reference to Distro::PackageWatcher
    Package = Evesync::OS::PackageWatcher
  end
end
