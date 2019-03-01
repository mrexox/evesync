require 'logger'

# This module is responsible for logging
module Sysmoon
  module Log
    # Supported levels for logging
    LEVELS = [:debug, :info, :warn, :error, :fatal]

    class << self
      def method_missing(m, *args)
        # You cannot setup logger from anywhere
        until LEVELS.include?(m)
          raise NoMethodError
        end

        check_logger
        @logger.send(m, to_string(*args))
      end

      def check_logger
        init_logger until @logger
      end

      def init_logger
        # Fixme: log into file, read from config
        @logger = Logger.new(STDERR)
        @logger.level = Logger::DEBUG
        @logger.formatter = proc do |sev, dtime, _prog, msg|
          time = dtime.strftime("%Y-%m-%d %H:%M:%S")
          prog = File.basename($0)
          "[#{time}] #{prog.ljust(8)} #{sev.ljust(5)}: #{msg}\n"
        end
      end

      def to_string(*args)
        to_s_with_space = lambda {|s| s.to_s + ' '}
        args.map(&to_s_with_space).reduce(&:+).strip
      end
    end
  end
end
