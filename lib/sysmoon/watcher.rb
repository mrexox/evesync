require 'sysmoon/log'
require 'sysmoon/watcher/files'
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
        @files_watcher = Sysmoon::Watcher::Files.new(@queue)
        @sysdatad = IPC::Client.new(:port => :sysdatad)
        @remote_syshands = [
          IPC::Client.new(
            :port => :syshand,
            :ip => '192.168.0.104'
          )
        ]
        Log.debug('Watcher initialized')
      end

      # Starts watchers threads
      #
      # [*Returns*] self
      def start
        @threads ||= []
        if @threads.empty?
          @threads << @pkg_watcher.run
          @threads << @files_watcher.run
          @threads << Thread.new { loop { biz } }
        end
        Log.debug('Watcher started')
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
            syshand.handle(change) # FIXME: add timeout
          end
        else
          Log.fatal("Error with data daemon: no response")
        end
      end
    end
  end
end
