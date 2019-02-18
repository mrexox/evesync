# TODO: add check if rpm exists
require_relative './rhel/package_watcher.rb'
require_relative './rhel/package_manager.rb'

PackageWatcher = RhelPackageWatcher
PackageManager = RhelPackageManager
