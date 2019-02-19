require 'logger'

# This module is responsible for logging
module Log
  def self.debug(*args)
    check_logger
    @logger.debug(to_string(*args))
  end

  def self.info(*args)
    check_logger
    @logger.info(to_string(*args))
  end

  def self.warn(*args)
    check_logger
    @logger.warn(to_string(*args))
  end

  def self.error(*args)
    check_logger
    @logger.error(to_string(*args))
  end

  def self.fatal(*args)
    check_logger
    @logger.fatal(to_string(*args))
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
