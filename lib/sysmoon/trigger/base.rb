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
    end
  end
end
