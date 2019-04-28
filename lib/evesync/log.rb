require 'logger'
require 'evesync/config'
require 'evesync/constants'

# This module is responsible for logging
module Evesync
  module Log
    # Supported levels for logging
    LEVELS = %i[debug info warn error fatal].freeze

    class << self
      def method_missing(m, *args)
        # You cannot setup logger from anywhere
        raise NoMethodError unless LEVELS.include?(m)

        check_logger
        @logger.send(m, to_string(*args))
        nil
      end

      def check_logger
        init_logger unless @logger
      end

      def level=(lvl)
        check_logger
        if lvl.is_a?(Symbol) or lvl.is_a?(String)
          @logger.level =
            begin
              Logger.const_get(lvl.to_s.upcase)
            rescue NameError
              Logger::DEBUG
            end
        end
      end

      def level
        check_logger
        @logger.level
      end

      def simple=(bool)
        init_logger unless @logger
        if bool
          @logger.formatter = proc do |_sev, _dt, _prog, msg|
            "#{msg}\n"
          end
        end
      end

      def init_logger
        @logger = Logger.new(STDERR)
        @logger.formatter = proc do |sev, dtime, _prog, msg|
          time = dtime.strftime('%Y-%m-%d %H:%M:%S')
          prog = File.basename($PROGRAM_NAME)
          "[#{time}] #{prog.ljust(8)} #{sev.ljust(5)}: #{msg}\n"
        end
      end

      def to_string(*args)
        to_s_with_space = ->(s) { "#{s} " }
        args.map(&to_s_with_space).reduce(&:+).strip
      end
    end
  end
end
