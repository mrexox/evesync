require 'syslog'
require 'logger'
require 'evesync/config'
require 'evesync/constants'


module Evesync

  # Logging via syslog
  module Log
    # Supported levels for logging
    LEVELS = %i[debug info notice warn error fatal]
    def LEVELS.less(a, b)
      (self.index(a) <=> self.index(b) or -1) >= 0
    end

    # Default engine for logging, one of (:io, :syslog)
    DEFAULT_ENGINE = :io

    # Log level mapping for syslog
    SYSLOG = {
      :debug  => Syslog::LOG_DEBUG,
      :info   => Syslog::LOG_INFO,
      :notice => Syslog::LOG_NOTICE,
      :warn   => Syslog::LOG_WARNING,
      :error  => Syslog::LOG_ERR,
      :fatal  => Syslog::LOG_CRIT,
      #:alert => Syslog::LOG_ALERT,
      #:emerg => Syslog::LOG_EMERG,
    }

    SYSLOG_OPTIONS = [
      Syslog::LOG_PID,
      Syslog::LOG_NOWAIT,
      Syslog::LOG_CONS,
      Syslog::LOG_PERROR,
    ].inject(&:|)

    SYSLOG_FACILITY = [
      Syslog::LOG_DAEMON,
      Syslog::LOG_LOCAL5,
    ].inject(&:|)

    # Public methods available via Log.method
    class << self

      LEVELS.each do |level|
        define_method(level) do |*args|
          check_logger
          return unless LEVELS.less(level, @level)

          case @engine
          when :syslog
            @logger.log(SYSLOG[level], to_string(*args))
          when :io
            @logger.send(level, to_string(*args))
          end

          nil           # prevent from being able to access the object
        end
      end

      def level=(lvl)
        check_logger
        raise "Unknown level #{lvl}" unless LEVELS.include? lvl
        @level = lvl
      end

      def level
        @level
      end

      def check_logger
        init_logger unless @logger
      end

      def engine=(engine)
        raise UnsupportedLogEngine.new(engine) \
          unless [:syslog, :io].member? engine
        @engine = engine
      end

      # Using syslog implementation
      def init_logger
        @engine ||= DEFAULT_ENGINE
        prog = File.basename($PROGRAM_NAME)

        case @engine
        when :syslog
          @logger = Syslog.open(prog, SYSLOG_OPTIONS, SYSLOG_FACILITY)

        when :io
          @logger = Logger.new("/var/log/evesync/#{prog}.log")
          @logger.formatter = proc do |sev, dtime, _prog, msg|
            time = dtime.strftime('%Y-%m-%d %H:%M:%S')
            "[#{time}] #{prog.ljust(8)} #{sev.ljust(5)}: #{msg}\n"
          end
        end

        @level  = :debug
      end

      def to_string(*args)
        to_s_with_space = ->(s) { "#{s} " }
        args.map(&to_s_with_space).reduce(&:+).strip
      end
    end
  end
end
