require 'find'

VERSION = '0.0.0'

GEMSPEC = 'sysmoon.gemspec'
GEM_FILE = "sysmoon-#{VERSION}.gem"

task :default => [:install, :clean]

task :install => [:build] do
  sh "gem install #{GEM_FILE}"
end

task :build do
  sh "gem build #{GEMSPEC}"
end

task :clean do
  rm_rf('tmp')
  rm_rf('doc')
  rm_rf(GEM_FILE)
end
