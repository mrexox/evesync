require 'sysmoon/ipc/data/file'

module Sysmoon
  module Watcher

    # File watcher
    #
    # = TODO:
    #   * Make it work, add inotify, separate configuration
    #     and buziness logic
    #
    class File
      def initialize(queue)

      end

      def run
        Thread.new {}
      end

      def ignore(file)
        @ignore << file if
          file.is_a? IPC::Data::File
      end
    end
  end
end
