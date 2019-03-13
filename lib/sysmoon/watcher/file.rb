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
        @main_thr.exit
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
        @events.each do |file, events|
          next if not ::File.exist? file
          event = guess_event(events)
          ipc_event = IPC::Data::File.new(
            :name => file,
            :mode => ::File::Stat.new(file).mode,
            :action => event,
            :touched_at => DateTime.now.to_s,
          )
          Log.debug("File #{file} #{event} guessed of #{events}")
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
        @inotify.watch(filename, :modify) { h_file(filename, [:modify]) }
        watch_directory_of_file filename
      end

      def watch_directory_of_file(filename)
        dir = ::File.dirname(filename)

        # FIXME: some bug
        @inotify.watch(dir, :create, :delete, :moved_to) { |e|
          Log.debug("watch_directory_of_file #{e.absolute_name}")
          h_directory_of_file(filename, e.flags) if e.absolute_name == filename
        }
      end

      def watch_directory(dirname)
        @inotify.watch(dirname, :create, :delete, :moved_to, :moved_from) { |e|
          Log.debug("watch_directory: #{e.absolute_name}")
          if ::File.exist? e.absolute_name
            h_directory(e.absolute_name, e.flags)
          end
        }
      end

      # Handlers of inotify changes

      def h_file(filename, events)
        Log.debug("h_file: #{filename}")

        unless @events[filename]
          @events[filename] = []
        end

        @events[filename] += events
      end

      def h_directory_of_file(filename, events)
        Log.debug("h_directory_of_file: #{filename}")

        unless @events[filename]
          @events[filename] = []
        end

        @events[filename] += events
        watch_file(filename)
      end

      def h_directory(filename, events)
        Log.debug("h_directory: #{filename}")

        if ::File.file? filename
          watch_file(filename)
        elsif ::File.directory? filename
          watch_directory(filename)
        end

        # Better pass a file
        unless @events[filename]
          @events[filename] = []
        end

        @events[filename] += events
      end

      def guess_event(events)
        if events.length == 1
          return events.first
        end

        if events.include? :create and events.include? :modify
          return :modify
        end

        if events.include? :delete and not events.include? :create
          return :delete
        end
        # TODO: find out more logic
        return events.last
      end
    end
  end
end
