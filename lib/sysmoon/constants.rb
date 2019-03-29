module Sysmoon
  module Constants
    CONFIG_FILE   = '/etc/sysmoon.conf'.freeze
    MOOND_PORT = '55443'
    DATAD_PORT = '54321'
    HAND_PORT  = '55432'
    WATCH_PERIOD = 2
    DB_PATH = '/var/lib/sysmoon/db/'
    DISCOVER_TIMEOUT = 3600
    FILES_PATH = '/var/lib/sysmoon/files/'
  end
end
