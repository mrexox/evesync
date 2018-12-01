require 'find'
require 'rake/extensiontask'

GEMSPEC = 'sysmoon.gemspec'
GEM_FILE = 'sysmoon-0.0.0.gem'

task :default => [:install, :clean]

task :install => [:test, :build] do
  sh "sudo gem install #{GEM_FILE}"
end

task :build do
  sh "gem build #{GEMSPEC}"
end

task :test => [:clean, :compile] do
  ruby '-Ilib', 'ext/inotify/test.rb'
end

Rake::ExtensionTask.new "inotify" do |ext|
  ext.lib_dir = "lib/inotify"
end

task :gem do

end

task :clean do
  # Cleaning extension
  Dir.chdir('ext/inotify') do
    File.file?('Makefile') && sh('make', 'clean') && rm('Makefile')
  end

  # Temporary files Emacs makes
  Find.find('.') do |path|
    next if ! File.file?(path) ||
            path =~ /\.git|doc|tmp/x
  end

  rm_rf('tmp')
  rm_rf('doc')
  rm_rf(GEM_FILE)
end
