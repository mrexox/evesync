require 'rb-inotify'
require 'sysmoon/configuration'
require 'sysmoon/ipc/data/file'

module Sysmoon
  module Watcher

    # = Synopsis
    #
    # Watches the files and directories, defined in
    # configuration attribute _watch_
    #
    # = TODO:
    #   * Make it work, add inotify, separate configuration
    #     and business logic
    #
    class File
      def initialize(queue)
        @queue = queue
        @ignore = []
        @watches = Configuration[:sysmoond]['watches']
        @inotify = INotify::Notifier.new
        initialize_watcher
      end

      def initialize_watcher
        # TODO: increase mas watched files
        # TODO: make them work fine
        @proc_file_modified = Proc.new {|event| event.absolute_name}
        @proc_watching_file_changed = Proc.new {|event| event.absolute_name}
        @proc_dir_changed = Proc.new {|event| event.absolute_name}

        @watches.each do |filename|
          unless File.exist? filename
            Log.error("#{self.class.name}: '#{filename}' absent on system")
          end

          if File.file? filename
            watch_file filename
          elsif File.directory? filename
            watch_dir filename
          else
            Log.warn("#{self.class.name}: watching '#{filename}' is not implemented yet")
          end
        end
      end

      def run
        @thread = Thread.new { @inotify.run }
      end

      def stop
        @thread.join # FIXME: maybe exit
      end

      def ignore(file)
        @ignore << file if
          file.is_a? IPC::Data::File
      end

      private

      def watch_file(filename)
        # add file modify watch
        @inotify.watch(filename, :modify, &@proc_file_modified)
        # add dir watch, that removes previous watcher
        #   and adds another watcher
        @inotify.watch(File.dirname(filename), :create, :move_to, &@proc_watching_file_changed)
      end

      def watch_dir(dirname)
        # watch dir for created and deleted files
        @inotify.watch(dirname, :create, :move_to, &@proc_dir_changed)
      end
    end
  end
end
