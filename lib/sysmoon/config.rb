require 'toml-rb'
require 'sysmoon/constants'
require 'sysmoon/log'

module Sysmoon
  module Config
    class << self
      def [](daemon)
        read_config if needs_reading

        @@config[daemon.to_s]
      end

      private

      def read_config
        @@config = TomlRB.load_file(Constants::CONFIG_FILE)
        # Setting unset defaults
        @@config['sysmoond']['port'] ||= Constants::MOOND_PORT
        @@config['sysdatad']['port'] ||= Constants::DATAD_PORT
        @@config['syshand']['port']  ||= Constants::HAND_PORT
        @@config['sync']['port']     ||= Constants::SYNC_PORT
        @@config['discover_timeout'] ||= Constants::DISCOVER_TIMEOUT
        Log.info("Config read: #{Constants::CONFIG_FILE}")
      end

      def needs_reading
        ! defined? @@config
      end
    end
  end
end
