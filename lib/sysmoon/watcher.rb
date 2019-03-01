require 'sysmoon/watcher/file'
require 'sysmoon/watcher/package'

module Sysmoon
  module Watcher

    # *Main* class responds for starting all watchers (e.g.
    # package and file). Watchers are initialized in their
    # own threads. Watcher::Main supports start/stop methods for
    # starting and stopping watchers.
    #
    # = Example:
    #
    #   w = Sysmoon::Watcher:Main.new
    #   w.start # so, all needful watchers are started
    #
    # = TODO:
    #   * Add ability to restart watchers if something happend
    #
    # = FIXME:
    #   * Remove +biz+ method, it's not save, reorganize code
    #
    class Main
      def initialize
        # Creating subwatchers
        @queue = Queue.new
        @pkg_watcher = Sysmoon::Watcher::Package.new(@queue)
        @file_watcher = Sysmoon::Watcher::File.new(@queue)
        @sysdata = IPC::Client.new(:port => :sysdatad)
        @remote_syshands = [
          IPC::Client.new(
            :port => :syshand,
            :ip => '172.168.22.134'
          )
        ]
      end

      # Starts watchers threads
      #
      # [*Returns*] self
      def start
        @threads ||= []
        unless @threads
          @threads << @handler.run
          @threads << @pkg_watcher.run
          @threads << @file_watcher.run
          @threads << Thread.new { loop { biz } }
        end
        self
      end

      # Stops all watcher threads
      def stop
        @threads.each(&:exit)
      end

      def ignore(change)
        # If Data::Package -> @package_handler.ignore
        # If Data::Files -> @files_handler.ignore
      end

      private

      def biz
        change = @queue.pop
        Log.info "#{self.class.name}: #{change}"
        response = @sysdatad.save(change)
        if response
          Log.info("Sysdata response:", response)
          @remote_syshands.each do |syshand|
            syshand.handle(change)
          end
        else
          Log.fatal("Error with data daemon: no response")
        end
      end
    end
  end
end
