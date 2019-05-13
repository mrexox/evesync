require 'timeout'
require 'evesync/log'
require 'evesync/config'
require 'evesync/ipc/client'
require 'evesync/watcher/file'
require 'evesync/watcher/package'

module Evesync

  # *Watcher* class responds for starting all watchers (e.g.
  # package and file). Watchers are initialized in their
  # own threads. Watcher::Main supports start/stop methods
  # or starting and stopping watchers.
  #
  # = Example:
  #
  #   w = Evesync::Watcher.new
  #   w.start # so, all needful watchers are started
  #
  # = TODO:
  #   * Add ability to restart watchers if something happend
  #
  class Watcher
    WATCHER_CLASSES = [
      Watcher::Package,
      Watcher::File
    ].freeze

    def initialize(queue)
      # Creating subwatchers
      Log.debug('Watcher initialization started...')
      @queue = queue
      @watchers = []
      WATCHER_CLASSES.each do |w_class|
        @watchers << w_class.new(@queue)
      end
      Log.debug('Watcher initialization done!')
    end

    # Starts watchers threads
    #
    # [*Returns*] self
    def start
      @threads ||= []
      if @threads.empty?
        @watchers.each do |watcher|
          @threads << watcher.start
        end
      end

      Log.debug('Watcher thread started')
      self
    end

    # Stops all watcher threads
    #
    # [*Returns*] self
    def stop
      @watchers.each do |watcher|
        @threads << watcher.stop
      end
      @threads.each(&:exit)

      Log.debug('Watcher threads stopped')
      self
    end
  end
end
