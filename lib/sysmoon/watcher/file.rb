require 'date'
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
        @watches = Configuration[:sysmoond]['watch']
        @period = Configuration[:sysmoond]['watch_interval'].to_i || Constants::WATCH_PERIOD
        @inotify = INotify::Notifier.new
        # @lock: avoid cleaning something that may be needed. May cause problems
        @lock = false
        @events = {}

        initialize_watcher
      end

      def run
        @inotify_thr = Thread.new { @inotify.run }
        @main_thr = Thread.new {
          loop do
            sleep @period
            send_events
          end
        }
      end

      def stop
        @inotify.stop
        @inotify_thr.join # FIXME: maybe exit
      end

      def ignore(file)
        @ignore << file if
          file.is_a? IPC::Data::File
      end

      private

      # Send all events from the methods-handlers
      # = FIXME:
      #   * make sure @lock is working as it's expected
      #   * maybe recall send_events if hash is updated
      #
      def send_events
        @events.each do |file, _events|
          next until ::File.exist? file
          ipc_event = IPC::Data::File.new(
            :name => file,
            :mode => ::File::Stat.new(file).mode,
            :action => :modify,
            :touched_at => DateTime.now.to_s,
          )
          Log.debug("File #{file} modified")
          @queue.push(ipc_event)
        end
        @events = {}
      end

      def initialize_watcher

        @watches.each do |filename|
          unless ::File.exist? filename
            Log.error("#{self.class.name}: '#{filename}' absent on system")
          end

          # TODO: ignore /dev and /sys, /proc directories
          if ::File.file? filename
            watch_file filename
            watch_directory_of_file filename
          elsif ::File.directory? filename
            watch_directory filename
          else
            # Seems to be a drive or
            Log.warn("#{self.class.name}: watching '#{filename}' is not implemented yet")
          end
        end
      end

      def watch_file(filename)
        # add file modify watch
        @inotify.watch(filename, :modify) { |e| h_file(e) }
      end

      def watch_directory_of_file(filename)
        # add dir watch, that removes previous watcher
        #   and adds another watcher
        @inotify.watch(::File.dirname(filename),
                       :create, :moved_to) { |e|
          h_directory_of_file(filename, e)
        }
      end

      def watch_directory(dirname)
        # watch dir for created and deleted files
        @inotify.watch(dirname,
                       :create, :moved_to, :moved_from) { |e|
          h_directory(e)
        }
      end

      # Handlers of inotify changes

      def h_file(event)
        Log.debug("w_file: #{event.absolute_name}")

        unless @events[event.absolute_name]
          @events[event.absolute_name] = []
        end

        @events[event.absolute_name] << event
      end

      def h_directory_of_file(filename, event)
        Log.debug("w_directory_of_file: #{event.absolute_name}")

        unless @events[event.absolute_name]
          @events[event.absolute_name] = []
        end

        @events[event.absolute_name] << event
        watch_file(filename)
      end

      def h_directory(event)
        file = event.absolute_name
        Log.debug("w_directory: #{file}")

        if ::File.file? file
          watch_file(file)
        elsif ::File.directory? file
          watch_directory(file)
        end

        # Better pass a file
        unless @events[file]
          @events[file] = []
        end

        @events[file] << event
      end

    end
  end
end
