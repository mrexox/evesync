require 'toml'
require 'sysmoon/constants'
require 'sysmoon/log'

module Sysmoon
  module Config

    def self.[](daemon)
      unless defined? @@config
        Log.info("Reading configuration file #{Constants::CONFIG_FILE}")
        @@config = TOML::load_file(Constants::CONFIG_FILE)

        # Setting unset defaults
        @@config['sysmoond']['port'] ||= Constants::MOOND_PORT
        @@config['sysdatad']['port'] ||= Constants::DATAD_PORT
        @@config['syshand']['port']  ||= Constants::HAND_PORT
        @@config['sysmoond']['discover_timeout'] ||= Constants::DISCOVER_TIMEOUT
      end

      @@config[daemon.to_s]
    end
  end
end
