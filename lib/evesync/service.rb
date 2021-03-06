require 'evesync/log'
require 'evesync/ipc/server'

require 'fileutils'

module Evesync
  # Class for creating daemons which are DRb servers with
  # proxy object to accept requests.
  #
  # Traps signals to exit.
  #
  # Example:
  #  d = Evesync::Service.new(:mydaemond) do |config|
  #    config.proxy = SomeProxyObject.new
  #  end
  #
  #  d.start
  #
  class Service
    def initialize(name)
      @factory = ServiceFactory.new
      @factory.name = name unless name.nil?
      yield @factory
    end

    def start
      daemonize

      Log.info("#{@factory.name} daemon starting...")

      @ipc_server = IPC::Server.new(
        port: @factory.port,
        proxy: @factory.proxy,
        ip: @factory.ip,
      ).start

      Signal.trap('TERM') do
        @ipc_server.stop
        exit 0
      end

      Log.info("#{@factory.name} daemon started!")

      @factory.at_start.call if @factory.at_start.respond_to? :call

      loop do
        sleep @factory.interval
        yield if block_given?
      end

    rescue SignalException => e
      Log.warn("#{@factory.name} daemon received signal: " \
               "#{e.signm}(#{e.signo})")
      exit 0

    # rubocop:disable Lint/RescueException
    rescue Exception => crit
      Log.fatal(crit)
      crit.backtrace.each { |line| Log.fatal(line) }
      exit 1

    # rubocop:enable Lint/RescueException
    ensure
      @factory.at_exit.call if @factory.at_exit.respond_to? :call
      @ipc_server.stop
      File.delete(@pidfile) if @pidfile
    end

    def daemonize
      Process.daemon
      Process.setproctitle(@factory.name.to_s) \
        if Process.respond_to? :setproctitle
      $0 = @factory.name.to_s
      FileUtils.mkdir_p @factory.pids
      @pidfile = "#{@factory.pids}/#{@factory.name}.pid"
      File.open(@pidfile, 'w') do |f|
        f.puts(Process.pid)
      end
    end
  end

  class ServiceFactory
    attr_accessor :name, :proxy, :at_start, :at_exit
    attr_writer   :interval, :port, :ip, :logs, :pids

    def logs
      @logs || '/var/log/evesync/'
    end

    def pids
      @pids || '/var/run/evesync/'
    end

    def port
      @port || name.to_sym
    end

    def ip
      @ip || 'localhost'
    end

    def interval
      @interval || 3600
    end
  end
end
