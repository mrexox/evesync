module Evesync
  class Watcher
    # Base watcher abstract class with methods for other
    # watchers to implement
    class Interface
      # The class must be initialized with the queue object
      def initialize(queue)
        raise NotImplementedError, "must implement 'initialize'"
      end

      # The watcher must be able to handle start and stop calls
      def start
        raise NotImplementedError, "must implement 'start'"
      end

      def stop
        raise NotImplementedError, "must implement 'stop'"
      end
    end
  end
end
