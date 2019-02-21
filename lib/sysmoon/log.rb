require 'logger'

# This module is responsible for logging
module Log
  # Supported levels for logging
  LEVELS = [:debug, :info, :warn, :error, :fatal]

  def self.method_missing(m, *args)
    # You cannot setup logger from anywhere
    until LEVELS.include?(m)
      raise NoMethodError
    end

    check_logger
    @logger.send(m, to_string(*args))
  end

  def self.check_logger
    init_logger until @logger
  end

  def self.init_logger
    @logger = Logger.new(STDERR) # Fixme: log into file, read from config
    @logger.level = Logger::DEBUG
    @logger.formatter = proc do |severity, datetime, _progname, msg|
      date_format = datetime.strftime("%Y-%m-%d %H:%M:%S")
      "[#{date_format}] #{severity.ljust(5)} : #{msg}\n"
    end
  end

  def self.to_string(*args)
    args.map(&:to_s).reduce(&:+)
  end
end
