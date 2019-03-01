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
    #
    #   Add ability to restart watchers if something happend
    #
    class Main
      def initialize
        # Creating subwatchers
        @pkg_watcher = Sysmoon::Watchers::Package.new(queue)
        @file_watcher = Sysmoon::Watchers::File.new(queue)
        @handler = Sysmoon::Handler::Local.new(queue)
      end

      # Starts watchers threads
      #
      # [*Returns*] self
      def start
        @threads ||= []
        @threads << @handler.run
        @threads << @pkg_watcher.run
        @threads << @file_watcher.run

        self
      end

      # Stops all watcher threads
      def stop
        @threads.each(&:exit)
      end
    end
  end
end
