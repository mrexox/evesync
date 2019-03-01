require_relative './arch/package_watcher.rb'
require_relative './arch/package_manager.rb'

module Sysmoon
  module Distro
    PackageWatcher = ArchPackageWatcher
    PackageManager = ArchPackageManager
  end
end
