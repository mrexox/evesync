require 'rake' # for FileList
require_relative 'lib/evesync'

Gem::Specification.new do |s|
  s.name = 'evesync'

  s.version = Evesync::VERSION

  s.license = 'BSD-2-Clause'

  s.date = '2019-02-12'

  s.summary = 'Daemons and utility for package and file changes synchronization'

  s.authors = 'Kiselev Valentine'
  s.email = 'mrexox@yahoo.com'
  s.homepage = 'https://mrexox.github.io'
  s.description = %q(Daemons and utility for package and file changes synchronization.)
  s.files = FileList[
    'doc/**/*',
    'bin/*',
    'LICENSE',
    'Rakefile',
    'lib/**/*.rb',
    'config/*.conf' # TODO: remove this line
  ]

  s.executables = %w[
    evemond
    evedatad
    evehand
    evesyncd
    evesync
  ]

  s.require_paths = %w[lib]
end
