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
        @logger = Logger.new(STDERR) # Fixme: log into file, read from config
        @logger.level = Logger::DEBUG
        @logger.formatter = proc do |severity, datetime, _progname, msg|
          date_format = datetime.strftime("%Y-%m-%d %H:%M:%S")
          progname = File.basename($0)
          "[#{date_format}] #{progname.ljust(8)} #{severity.ljust(5)}: #{msg}\n"
        end
      end

      def to_string(*args)
        to_s_with_space = lambda {|s| s.to_s + ' '}
        args.map(&to_s_with_space).reduce(&:+).strip
      end
    end
  end
end
