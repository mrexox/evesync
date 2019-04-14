require 'date'
require 'rb-inotify'
require 'sysmoon/config'
require 'sysmoon/ipc/data/file'

module Sysmoon
  class Watcher
    # = Synopsis
    #
    # Watches the files and directories, defined in
    # configuration attribute _watch_
    #
    # = TODO:
    #   * Test on various cases, make it work properly
    #   * Find out all possible occasions
    #
    class File
      def initialize(queue)
        @queue = queue
        @watches = Config[:sysmoond]['watch']
        @period = Config[:sysmoond]['watch_interval'].to_i || Constants::WATCH_PERIOD
        @inotify = INotify::Notifier.new
        @events = {}
        @wfiles = []
        @wdirs = []
        initialize_watcher
      end

      def run
        @inotify_thr = Thread.new { @inotify.run }
        @main_thr = Thread.new do
          loop do
            sleep @period
            send_events
          end
        end
      end

      def stop
        @inotify.stop
        @inotify_thr.join # FIXME: maybe exit
        @main_thr.exit
      end

      private

      # Send all events from the methods-handlers
      def send_events
        @events.each do |file, events|
          event = guess_event(events)
          mode = case event
                 when :delete then nil
                 else ::File::Stat.new(file).mode
                 end

          msg = IPC::Data::File.new(
            name: file,
            mode: mode,
            action: event,
            touched_at: DateTime.now.to_s
          )
          @queue.push msg
          Log.debug("File #{file} #{event} guessed " \
                    "of #{events}")
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
        Log.debug("Added watch_file #{filename}")

        @inotify.watch(filename, :modify) do |e|
          Log.debug("h_file worked for #{e.absolute_name}")
          h_file(e.absolute_name, [:modify]) # the only flag we need
        end

        # Waiting for file to disappear and created again
        @wfiles << filename unless @wfiles.include?(filename)
        dirname = ::File.dirname(filename)
        unless @wdirs.include?(dirname)
          watch_directory_for_file(dirname)
          @wdirs << dirname
        end
      end

      def watch_directory(dirname)
        @inotify.watch(dirname, :create, :delete, :moved_to, :moved_from) do |e|
          Log.debug("watch_directory: #{e.absolute_name}")
          h_directory(e.absolute_name, e.flags)
        end
      end

      def watch_directory_for_file(dirname)
        @inotify.watch(dirname, :create, :moved_to) do |e|
          watch_file(e.absolute_name) if @wfiles.include? e.absolute_name
        end
      end

      # Handlers of inotify changes

      def h_file(filename, events)
        Log.debug("h_file: #{filename}")

        @events[filename] = [] unless @events[filename]

        @events[filename] += events
      end

      # FIXME: remove
      def h_directory_for_file(filename, events)
        Log.debug("h_directory_of_file: #{filename}")

        @events[filename] = [] unless @events[filename]

        @events[filename] += events
        watch_file(filename)
      end

      def h_directory(filename, events)
        Log.debug("h_directory: #{filename}")

        if ::File.file? filename
          watch_file(filename)
          @watches << filename unless @watches.include? filename
        elsif ::File.directory? filename
          watch_directory(filename)
        end

        # Better pass a file
        @events[filename] = [] unless @events[filename]

        @events[filename] += events
      end

      def guess_event(events)
        return events.first if events.length == 1

        return :modify if events.include?(:create) && events.include?(:modify)

        return :delete if events.include?(:delete) && (!events.include? :create)

        # TODO: find out more logic
        events.last
      end
    end
  end
end
