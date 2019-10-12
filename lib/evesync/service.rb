require 'evesync/log'
require 'evesync/ipc/server'

module Evesync
  class Service
    def initialize(name)
      @factory = ServiceFactory.new
      @factory.name = name unless name.nil?
      yield @factory
      p @factory.logs
    end

    def start
      # TODO: double fork
      # TODO: chdir
      # TODO: setsid

      Evesync::Log.info("#{@factory.name} daemon starting...")

      @ipc_server = Evesync::IPC::Server.new(
        port: @factory.port,
        proxy: @factory.proxy
      ).start

      Signal.trap('TERM') do
        @ipc_server.stop
        exit 0
      end

      Evesync::Log.info("#{@factory.name} daemon started!")

      loop { sleep @factory.repeat_interval }
    rescue SignalException => e
      Evesync::Log.warn("#{@factory.name} daemon received signal: " \
                        "#{e.signm}(#{e.signo})")
    ensure
      @ipc_server.stop
    end
  end

  class ServiceFactory
    attr_accessor :name, :proxy, :port,
                  :repeat_code, :repeat_interval,
                  :at_start, :at_exit, :logs, :pids

    def logs
      @logs || '/var/log/evesync/'
    end

    def pids
      @pids || '/var/run/evesync/'
    end

    def port
      @port || name.to_sym
    end

    def repeat_interval
      @repeat_interval || 3600
    end
  end

end
