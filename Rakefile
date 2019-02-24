require 'find'
require 'mkmf'

VERSION = '0.0.0'.freeze

GEMSPEC = 'sysmoon.gemspec'.freeze
GEMFILE = "sysmoon-#{VERSION}.gem".freeze

task default: %i[lint rdoc install clean]

task :lint do
  if find_executable 'rubocop' then sh 'rubocop -l' end
end

task :rdoc do
  sh 'rdoc --ri'
  sh 'rdoc'
end

task install: [:build] do
  sh "gem install --local #{GEMFILE}"
end

task :build do
  sh "gem build #{GEMSPEC}"
end

task :clean do
  rm_rf('tmp')
  rm_rf('doc')
  rm_rf(GEMFILE)
end

task todos: :todo
task :todo do
  puts ":><: \033[0;31mTODOs\033[0m in code"
  puts `find bin lib dockerfiles -type f -exec grep --color=always TODO   \{} \+ ||:`
  puts ":><: \033[0;31mFIXMEs\033[0m in code"
  puts `find bin lib dockerfiles -type f -exec grep --color=always FIXME  \{} \+ ||:`
end
