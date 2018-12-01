require 'find'
require 'rake/extensiontask'

task :default => [:test]

task :install => [:clean, :compile]

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
end
