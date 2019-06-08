module Evesync
  module Constants
    MOOND_PORT = '55443'.freeze
    DATAD_PORT = '54321'.freeze
    HAND_PORT  = '55432'.freeze
    SYNC_PORT  = '64653'.freeze

    CONFIG_FILE   = '/etc/evesync.conf'.freeze
    DB_PATH       = '/var/lib/evesync/db/'.freeze
    DB_FILES_PATH = '/var/lib/evesync/files/'.freeze

    DEFAULT_LOGLEVEL = 'info'.freeze

    DISCOVER_TIMEOUT = 3600
    WATCH_INTERVAL   = 2
  end
end
