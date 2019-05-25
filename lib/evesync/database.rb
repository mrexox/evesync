require 'fileutils'
require 'json'
require 'lmdb'
require 'evesync/config'
require 'evesync/constants'
require 'evesync/ipc/data/package'
require 'evesync/ipc/data/file'
require 'evesync/ipc/data/ignore'

module Evesync

  ##
  # *Database* class is a proxy for *evedatad* daemon
  # implements at least one method: +save+. Allows
  # Local +evemond+ save messages about changes
  #
  # Messages should be serializable (JSON)
  #
  # TODO:
  #  * Think about how it can be widened

  class Database
    def initialize(db_path=nil, db_files_path=nil)
      path = db_path || Config[:evedatad]['db_path']

      unless ::File.exist? path
        # FIXME: only root. handle exception
        FileUtils.mkdir_p(path)
      end
      @env = LMDB.new(path)
      @db = @env.database
      @files_path = db_files_path || Config[:evedatad]['db_files_path']
    end

    # Save message to database, key is timestamp+object
    def save(message)
      Log.debug("Database save: #{message}")
      db_add_entry(message)

      if message.is_a? Evesync::IPC::Data::File
        Log.debug("Database save file action: #{message.action}")
        unless message.action ==
               IPC::Data::File::Action::DELETE
          save_file(message)
        end
      end
      true
    end

    # Events simplified: object => [timestamp...]
    def events
      events = {}
      @db.each do |key, _|
        timestamp, object = parse_event(key)
        events[object] ||= []
        events[object].push(timestamp)
      end
      events
    end

    # Messages for events: object => {timestamp => message}
    def messages(events)
      ev_msgs = {}
      @db.each do |key, message|
        timestamp, object = parse_event(key)
        next unless events.include?(object)

        ev_msgs[object] ||= {}
        if events[object].include?(timestamp)
          ev_msgs[object][timestamp] = message
        end
      end
      ev_msgs
    end

    private

    def db_add_entry(message)
      Log.debug('Database adding entry...')
      key = create_key(message)
      value = create_value(message)
      @db[key] = value
      Log.debug('Database adding entry done!')
    end

    def create_key(message)
      "#{message.timestamp}_#{message.name}"
    end

    def create_value(message)
      message.to_hash.to_json
    end

    def parse_event(key)
      key.split('_', 2)
    end

    def save_file(file)
      Log.debug('Database saving file...')
      fulldest = File.join(@files_path,
                           file.name + ".#{file.timestamp}")
      FileUtils.mkdir_p(File.dirname(fulldest))
      FileUtils.cp(file.name, fulldest)
      Log.debug('Database saving file done!')
    end
  end
end
