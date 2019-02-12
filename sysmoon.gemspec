require 'rake' # for FileList

Gem::Specification.new do |s|

  s.name = %q{sysmoon}

  s.version = "0.0.0"

  s.license = 'BSD 2-Clause'

  s.date = %q{2019-02-12}

  s.summary = %q{Sys changes monitor}

  s.authors = "Kiselev Valentine"

  s.files = FileList[
    'bin/*',
    'LICENSE',
    'Rakefile',
    'lib/**/*.rb'
  ]

  s.executables << 'sysmoond'

  s.require_paths = %w[lib src]

end
