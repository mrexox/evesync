require 'fileutils'
require 'json'
require 'lmdb'
require 'sysmoon/config'
require 'sysmoon/constants'
require 'sysmoon/ipc/data/package'
require 'sysmoon/ipc/data/file'
require 'sysmoon/ipc/data/ignore'


module Sysmoon
  class Trigger

    # = Synopsis:
    #
    # *Database* class is a proxy for *sysdatad* daemon
    # implements at least one method: +save+. Allows
    # Local +sysmoond+ save messages about changes
    #
    # Messages should be serializable (JSON)
    #
    # = TODO:
    #  * Think about how it can be widened
    #
    class Database
      def initialize
        path = Config[:sysdatad]['db_path'] ||
               Constants::DB_PATH
        unless ::File.exist? path
          # FIXME: only root. handle exception
          FileUtils.mkdir_p(path)
        end
        @env = LMDB.new(path)
        @db = @env.database
        @files_path = Config[:sysdatad]['db_path'] ||
                      Constants::FILES_PATH
      end

      def save(message)
        Log.debug("Data handler called: #{message}")
        db_add_entry(message)
        if message.is_a? Sysmoon::IPC::Data::File
          Log.debug("Is a File #{message.action}")
          unless message.action == IPC::Data::File::Action::DELETE

            save_file(message)
          end
        end
        'Fine'
      end

      private

      def db_add_entry(message)
        Log.debug('Adding DB entry')
        @db[message.timestamp] = message.to_hash.to_json
        Log.debug('DB entry added')
      end

      def save_file(file)
        Log.debug('Saving file...')
        fulldest = File.join(@files_path,
                             file.name + ".#{file.timestamp}")
        FileUtils.mkdir_p(File.dirname(fulldest))
        FileUtils.cp(file.name, fulldest)
        Log.debug('File saved!')
      end
    end
  end
end
