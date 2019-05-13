text = File.new('/etc/os-release').read

if text =~ /^ID.*(rhel|centos|fedora)/
  require 'evesync/os/linux/rhel'
elsif text =~ /ID.*arch/
  require 'evesync/os/linux/arch'
elsif text =~ /ID.*debian/
  require 'evesync/os/linux/deb'
end
