task :default => [:extension]

task :extension => :clean do
    Dir.chdir('ext/inotify') do
        ruby 'extconf.rb'
        sh 'make'
        ruby 'test.rb'
    end
end

task :clean do
  Dir.chdir('ext/inotify') do
    File.file?('Makefile') && sh('make', 'clean')
  end
end
