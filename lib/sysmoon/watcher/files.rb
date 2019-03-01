module Sysmoon
  module Watcher

    # Files watcher
    #
    # = TODO:
    #   * Make it work, add inotify, separate configuration
    #     and buziness logic
    #
    class Files
      def initialize(queue)

      end

      def run
        Thread.new {}
      end
    end
  end
end
