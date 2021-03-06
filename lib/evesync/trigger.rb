require 'evesync/trigger/file'
require 'evesync/trigger/package'
require 'evesync/config'
require 'evesync/log'
require 'evesync/ipc/client'
require 'evesync/utils'

module Evesync
  class Trigger
    def initialize(watcher_queue)
      @watcher_queue = watcher_queue

      # Local Data daemon
      evedatad = IPC::Client.new(port: :evedatad)

      @remote_handlers = Config[:evemond]['remotes'].map do |ip|
        new_remote_handler(ip)
      end.compact # remove nils

      # Helper triggers
      package_trigger = Trigger::Package.new(
        db: evedatad,
        remotes: @remote_handlers
      )

      file_trigger = Trigger::File.new(
        db: evedatad,
        remotes: @remote_handlers
      )

      @triggers = [package_trigger, file_trigger]

      Log.debug('Trigger initialization done!')
    end

    def start
      @thr = Thread.new do
        loop { biz }
      end
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
        remote_handler = new_remote_handler(ip)
        @remote_handlers << remote_handler if remote_handler
      end
      Log.debug 'Trigger actual remote nodes:', @remote_handlers.map(&:ip)
    end

    attr_reader :remote_handlers

    private

    # Main thread business logic goes here
    def biz
      change = @watcher_queue.pop
      Log.info "Trigger dequed event: #{change}"
      trigger = message_trigger(change)
      trigger.process(change)
    end

    # Send a method to target (choose by change class name)
    def trigger_method(method, change)
      Log.debug("Trigger calling '#{method}' on '#{change.class.name}'")

      trigger = message_trigger(change)

      if trigger
        trigger.send(method, change) && true
      else
        # TODO: forward somewhere
        Log.error('Trigger: no watchers will be notified on ' \
                  "#{change}")
      end
    end

    def message_trigger(message)
      class_last = message.class.name.to_s.split('::')[-1]
      @triggers.find do |trigger|
        trigger.to_s.include? class_last
      end
    end

    def new_remote_handler(ip)
      unless Utils.local_ip?(ip)
        IPC::Client.new(
          port: :evehand,
          ip: ip
        )
      end
    end
  end
end
