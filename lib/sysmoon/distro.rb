# FIXME: rewrite for more beautiful code

text = File.new("/etc/os-release").read

if text =~ /^ID.*(rhel|centos|fedora)/
  require 'sysmoon/distro/rhel'
elsif text =~ /ID.*arch/
  require 'sysmoon/distro/arch'
end
