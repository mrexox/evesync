require 'rake' # for FileList

Gem::Specification.new do |s|
  s.name = 'sysmoon'

  s.version = '0.0.0'

  s.license = 'BSD-2-Clause'

  s.date = '2019-02-12'

  s.summary = 'Sys changes monitor'

  s.authors = 'Kiselev Valentine'
  s.email = 'mrexox@yahoo.com'
  s.homepage = 'https://mrexox.github.io'
  s.description = 'System monitor and synchronization daemons'
  s.files = FileList[
    'doc/**/*',
    'bin/*',
    'LICENSE',
    'Rakefile',
    'lib/**/*.rb',
    'config/*.conf' # TODO: remove this line
  ]

  s.executables = %w[
    sysmoond
    sysdatad
    syshand
    syssyncd
  ]

  s.require_paths = %w[lib src]
end
