Gem::Specification.new do |s|

  s.name = %q{sysmoon}

  s.version = "0.0.0"

  s.date = %q{2018-12-01}

  s.summary = %q{}

  s.authors = "Kiselev Valentine"

  s.files = %w[
    LICENSE
    Rakefile
    lib/inotify.rb
    ext/inotify/inotify.c
    ext/inotify/wd_list.c
    ext/inotify/wd_list.h
    ext/inotify/test.rb
  ]

  s.require_paths = %w[lib src]
  s.extensions = %w[ext/inotify/extconf.rb]

end
