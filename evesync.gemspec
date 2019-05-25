require 'rake' # for FileList
require_relative 'lib/evesync'

Gem::Specification.new do |s|
  s.name = 'evesync'

  s.version = Evesync::VERSION

  s.license = 'BSD-2-Clause'

  s.date = '2019-02-12'

  s.required_ruby_version = '>= 2.0.0'

  s.summary = 'Daemons and utility for package and file changes synchronization'

  s.authors = 'Kiselev Valentine'
  s.email = 'mrexox@yahoo.com'
  s.homepage = 'https://mrexox.github.io'
  s.description = %q(Daemons and utility for package and file changes synchronization.)
  s.files = FileList[
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

  s.add_runtime_dependency 'full_dup'
  s.add_runtime_dependency 'hashdiff'
  s.add_runtime_dependency 'lmdb'
  s.add_runtime_dependency 'rb-inotify', '0.9.9' # Last available on ruby 2.0.0
  s.add_runtime_dependency 'toml-rb'
  s.add_runtime_dependency 'rubyzip'
  s.add_runtime_dependency 'net-ntp'
  s.required_ruby_version = '>= 2.0.0'

end
