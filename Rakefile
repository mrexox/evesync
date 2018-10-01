task :default => [:extension]

task :extension do
    Dir.chdir('ext/inotify') do
        File.file?('Makefile') && sh('make', 'clean')
        ruby 'extconf.rb'
        sh 'make'
        ruby 'test.rb'
    end
end

