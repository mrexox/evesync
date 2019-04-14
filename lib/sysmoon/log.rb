require 'logger'

# This module is responsible for logging
module Sysmoon
  module Log
    # Supported levels for logging
    LEVELS = %i[debug info warn error fatal].freeze

    class << self
      def method_missing(m, *args)
        # You cannot setup logger from anywhere
        raise NoMethodError until LEVELS.include?(m)

        check_logger
        @logger.send(m, to_string(*args))
        nil
      end

      def check_logger
        init_logger until @logger
      end

      def init_logger
        # FIXME: log into file, read from config
        @logger = Logger.new(STDERR)
        @logger.level = Logger::DEBUG
        @logger.formatter = proc do |sev, dtime, _prog, msg|
          time = dtime.strftime('%Y-%m-%d %H:%M:%S')
          prog = File.basename($PROGRAM_NAME)
          "[#{time}] #{prog.ljust(8)} #{sev.ljust(5)}: #{msg}\n"
        end
      end

      def to_string(*args)
        to_s_with_space = ->(s) { s.to_s + ' ' }
        args.map(&to_s_with_space).reduce(&:+).strip
      end
    end
  end
end
