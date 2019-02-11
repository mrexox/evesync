require 'find'

VERSION = '0.0.0'

GEMSPEC = 'sysmoon.gemspec'.freeze
GEMFILE = "sysmoon-#{VERSION}.gem".freeze

task :default => [:install, :clean]

task :install => [:build] do
  sh "gem install #{GEMFILE}"
end

task :build do
  sh "gem build #{GEMSPEC}"
end

task :clean do
  rm_rf('tmp')
  rm_rf('doc')
  rm_rf(GEMFILE)
end

task :todos => :todo
task :'list-todos' => :todo
task :todo do
  puts ":><: \033[0;31mTODOs\033[0m in code"
  puts `find . -name '*.rb' -exec grep --color=always TODO   \{} \+ ||:`
  puts ":><: \033[0;31mFIXMEs\033[0m in code"
  puts `find . -name '*.rb' -exec grep --color=always FIXME  \{} \+ ||:`
end
