require 'timeout'
require 'sysmoon/log'
require 'sysmoon/config'
require 'sysmoon/ipc/client'
require 'sysmoon/watcher/file'
require 'sysmoon/watcher/package'

module Sysmoon
  # = Synopsis
  #   *Watcher* class responds for starting all watchers (e.g.
  #   package and file). Watchers are initialized in their
  #   own threads. Watcher::Main supports start/stop methods
  #   for starting and stopping watchers.
  #
  # = Example:
  #
  #   w = Sysmoon::Watcher.new
  #   w.start # so, all needful watchers are started
  #
  # = TODO:
  #   * Add ability to restart watchers if something happend
  #
  # = FIXME:
  #   * Remove +biz+ method, it's not save, reorganize code
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
          @threads << watcher.run
        end
      end
      Log.debug('Watcher thread started')
      self
    end

    # Stops all watcher threads
    def stop
      @threads.each(&:exit)
      Log.debug('Watcher thread stopped')
    end
  end
end
