text = File.new('/etc/os-release').read

if text =~ /^ID.*(rhel|centos|fedora)/
  require 'sysmoon/distro/rhel'
elsif text =~ /ID.*arch/
  require 'sysmoon/distro/arch'
elsif text =~ /ID.*debian/
  require 'sysmoon/distro/deb'
end
