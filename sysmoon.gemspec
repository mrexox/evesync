require 'rake' # for FileList

Gem::Specification.new do |s|

  s.name = %q{sysmoon}

  s.version = "0.0.0"

  s.date = %q{2018-12-01}

  s.summary = %q{Sys changes monitor}

  s.authors = "Kiselev Valentine"

  s.files = FileList[
    'bin/*',
    'ext/**/*.{rb,c,h}',
    'LICENSE',
    'Rakefile',
    'lib/**/*.{rb,so}'
  ]

  s.require_paths = %w[lib src]
  s.extensions = %w[ext/inotify/extconf.rb]

end
