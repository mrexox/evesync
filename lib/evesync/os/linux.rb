text = File.new('/etc/os-release').read

if text =~ /^ID.*(rhel|centos|fedora)/
  require 'evesync/os/linux/rhel'
  EVESYNC_OS = 'rhel'.freeze
elsif text =~ /ID.*arch/
  require 'evesync/os/linux/arch'
  EVESYNC_OS = 'arch'.freeze
elsif text =~ /ID.*debian/
  require 'evesync/os/linux/deb'
  EVESYNC_OS = 'deb'.freeze
else
  EVESYNC_OS = 'not implemented'
end
