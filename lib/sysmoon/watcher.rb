require 'timeout'
require 'drb'
require 'sysmoon/log'
require 'sysmoon/configuration'
require 'sysmoon/utils'
require 'sysmoon/ipc/client'
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

      WATCHER_CLASSES = [Watcher::Package, Watcher::File]

      def initialize
        # Creating subwatchers
        @queue = Queue.new
        @watchers = []
        WATCHER_CLASSES.each do |w_class|
          @watchers << w_class.new(@queue)
        end
        @sysdatad = IPC::Client.new(:port => :sysdatad)
        @remote_syshands = Configuration[:sysmoond]['remotes'].map {|ip|
          unless Utils::local_ip?(ip)
            next IPC::Client.new(
              :port => :syshand,
              :ip => ip
            )
          end
        }.compact
        Log.debug('Watcher initialized')
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
          @threads << (Thread.new { loop { biz } })
        end
        Log.debug('Watcher started')
        self
      end

      # Stops all watcher threads
      def stop
        @threads.each(&:exit)
      end

      def ignore(change)
        Log.debug("Ignore: #{change.class.name}")
        # FIXME: this is dirty
        basic_class_name = change.class.name.split('::')[-1]

        handler = @watchers.find { |w|
          w.class.name.include? basic_class_name
        }

        if handler
          handler.ignore(change)
        else
          # TODO: forward somewhere
          Log.info("No watcher was notified to ignore #{change}")
        end

      end

      private

      def biz
        change = @queue.pop
        Log.info "#{self.class.name}: #{change}"
        response = @sysdatad.save(change)
        if response
          Log.info("Sysdata response:", response)
          @remote_syshands.each do |syshand|
            begin
              Timeout::timeout(30) {
                syshand.handle(change) # FIXME: add timeout
              }
            rescue Timeout::Error
              Log.warn("Syshand server #{syshand.uri} is not accessible")
            end
          end
        else
          Log.fatal("Error with data daemon: no response")
        end
      end
    end
  end
end
