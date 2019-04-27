text = File.new('/etc/os-release').read

if text =~ /^ID.*(rhel|centos|fedora)/
  require 'evesync/distro/rhel'
elsif text =~ /ID.*arch/
  require 'evesync/distro/arch'
elsif text =~ /ID.*debian/
  require 'evesync/distro/deb'
end
