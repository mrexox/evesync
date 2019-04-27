module Evesync
  module Constants
    CONFIG_FILE = '/etc/evesync.conf'.freeze
    MOOND_PORT = '55443'.freeze
    DATAD_PORT = '54321'.freeze
    HAND_PORT  = '55432'.freeze
    SYNC_PORT  = '64653'.freeze
    WATCH_INTERVAL = 2
    DB_PATH = '/var/lib/evesync/db/'.freeze
    DISCOVER_TIMEOUT = 3600
    FILES_PATH = '/var/lib/evesync/files/'.freeze
    DEFAULT_LOGLEVEL = 'debug'.freeze
  end
end
