require 'sysmoon/trigger/base'

module Sysmoon
  class Trigger
    class File
      include Base

      def intialize(params)
        @ignore = []
        @db = params[:db]
        @remotes = params[:remotes]
      end

      def process(file_message)
        if save_to_db(@db, file_message)
          send_to_remotes(@remotes, file_message)
        end
      end

      def ignore(file)
        @ignore << file
      end

      def unignore
        # FIXME: Change in future
        @ignore.pop
      end
    end
  end
end
