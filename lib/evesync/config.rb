require 'toml-rb'
require 'evesync/constants'
require 'evesync/log'

module Evesync
  module Config
    class << self

      DEFAULTS = {
        'evemond' => {
          'port'           => Constants::MOOND_PORT,
          'remotes'        => [],
          'watch'          => [],
          'watch_interval' => Constants::WATCH_INTERVAL
        },
        'evedatad' => { 'port' => Constants::DATAD_PORT },
        'evehand'  => { 'port' => Constants::HAND_PORT },
        'sync'     => { 'port' => Constants::SYNC_PORT },
        'discover_timeout' => Constants::DISCOVER_TIMEOUT
      }


      def [](daemon)
        read_config if needs_reading

        @@config[daemon.to_s]
      end

      private

      def read_config
        config = begin
                   TomlRB.load_file(Constants::CONFIG_FILE)
                 rescue StandardError => e
                   Log.error("Config ERROR: Couldn't parse file #{Constants::CONFIG_FILE}")
                   Log.error("Config ERROR MESSAGE: #{e}")
                   Log.error("Config ERROR: Using default configuration")
                   {}
                 end
        @@config = DEFAULTS.merge(config)
        Log.info("Config initialized!")
      end

      def needs_reading
        ! defined? @@config
      end
    end
  end
end
