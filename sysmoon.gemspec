require 'rake' # for FileList

Gem::Specification.new do |s|

  s.name = %q(sysmoon)
  
  s.version = %q(0.0.0)

  s.license = %q(BSD-2-Clause)

  s.date = %q(2019-02-12)

  s.summary = %q(Sys changes monitor)

  s.authors = %q(Kiselev Valentine)
  s.email = %q(mrexox@yahoo.com)
  s.homepage = %q(https://mrexox.github.io)
  s.description = %q(System monitor and synchronization daemons)
  s.files = FileList[
    'doc/**/*',
    'bin/*',
    'LICENSE',
    'Rakefile',
    'lib/**/*.rb',
    'config/*.conf' #TODO: remove this line
  ]

  s.executables = [
    'sysmoond', 
    'sysdatad', 
    'syshand',
    'syssyncd',
  ]

  s.require_paths = %w[lib src]

end
