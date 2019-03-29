require 'sysmoon/trigger/file'
require 'sysmoon/trigger/package'
require 'sysmoon/config'
require 'sysmoon/log'
require 'sysmoon/ipc/client'
require 'sysmoon/utils'

module Sysmoon
  class Trigger
    def initialize(watcher_queue)
      @watcher_queue = watcher_queue

      # Local Data daemon
      sysdatad = IPC::Client.new(:port => :sysdatad)

      @remote_handlers = Config[:sysmoond]['remotes'].map {|ip|
        new_remote_handler(ip)
      }.compact                 # remove nils

      # Helper triggers
      package_trigger = Trigger::Package.new(
        db: sysdatad,
        remotes: @remote_handlers
      )
      file_trigger = Trigger::File.new(
        db: sysdatad,
        remotes: @remote_handlers
      )

      @triggers = [package_trigger, file_trigger]

      Log.debug('Trigger initialized')
    end

    def start
      @thr = Thread.new {
        loop { biz }
      }
      Log.debug('Trigger started')
    end

    def stop
      @thr.exit
      Log.debug('Trigger stopped')
    end

    def ignore(change)
      trigger_method(:ignore, change)
    end

    def unignore(change)
      trigger_method(:unignore, change)
    end

    def add_remote_node(ip)
      unless @remote_handlers.find { |h| h.ip == ip }
        @remote_handlers.push new_remote_handler(ip)
      end
      true
    end

    private

    # Main thread business logic goes here
    def biz
      change = @watcher_queue.pop
      Log.info "#{self.class.name}: #{change}"
      trigger = message_trigger(change)
      trigger.process(change)
    end

    # Send a method to target (choose by change class name)
    def trigger_method(method, change)
      Log.debug("#{method.capitalize}: #{change.class.name}")

      trigger = message_trigger(change)

      if trigger
        trigger.send(method, change) && true
      else
        # TODO: forward somewhere
        Log.error("No watcher was notified to unignore " \
                  "#{change}")
      end
    end

    def message_trigger(message)
      class_last = message.class.name.to_s.split('::')[-1]
      @triggers.find { |trigger|
        trigger.to_s.include? class_last
      }
    end

    def new_remote_handler(ip)
      unless Utils::local_ip?(ip)
        IPC::Client.new(
          :port => :syshand,
          :ip => ip
        )
      end
    end
  end
end
