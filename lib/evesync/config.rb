require 'toml-rb'
require 'evesync/utils'
require 'evesync/constants'
require 'evesync/log'

module Evesync
  module Config
    class << self

      DEFAULTS = {
        'loglevel' => Constants::DEFAULT_LOGLEVEL,
        'ntp' => '',
        'evemond' => {
          'port'           => Constants::MOOND_PORT,
          'remotes'        => [],
          'watch'          => [],
          'watch_interval' => Constants::WATCH_INTERVAL
        },
        'evedatad' => {
          'port'           => Constants::DATAD_PORT,
          'db_path'        => Constants::DB_PATH,
          'db_files_path'  => Constants::DB_FILES_PATH
        },
        'evehand'  => {
          'port' => Constants::HAND_PORT
        },
        'evesyncd' => {
          'port' => Constants::SYNC_PORT
        },
        'discover_timeout' => Constants::DISCOVER_TIMEOUT
      }


      def [](param)
        config[param.to_s]
      end

      def reread
        read_config
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
        @@config = DEFAULTS.deep_merge(config)
        Log.info("Config initialized!")
      end

      def config
        read_config if ! defined? @@config
        @@config
      end
    end
  end
end
