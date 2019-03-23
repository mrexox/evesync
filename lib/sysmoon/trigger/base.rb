require 'timeout'
require 'sysmoon/log'

module Sysmoon
  class Trigger
    module Base
      # db must have a realization of _save_ method
      def save_to_db(db, message)
        db.save(message)
      end

      # Every element in *remotes* must have a realization
      # of _handle_ method
      def send_to_remotes(remotes, message)
        remotes.each do |syshand|
          begin
            Timeout::timeout(30) { # FIXME: take from Config
              syshand.handle(message)
            }
          rescue Timeout::Error
            Log.warn("Syshand server #{syshand.uri} " \
                     "is not accessible")
          end
        end
      end

      def process(message)
        if ignore?(message)
          unignore(message)
          false
        else
          if save_to_db(@db, message)
            send_to_remotes(@remotes, message)
            true
          end
        end
      end

      def ignore(ipc_data)
        @ignore << ipc_data if
          ipc_data.is_a? @@data_class
      end

      def unignore(ipc_data)
        @ignore.delete_if { |d| d == ipc_data }
      end

      private

      def ignore?(ipc_data)
        Log.debug("File ignore aray: #{@ignore}")
        @ignore.find { |d| d == ipc_data }
      end
    end
  end
end
