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

      def process()
        if save_to_db(@db)
          send_to_remotes(@remotes)
        end
      end

      def ignore(file)
        @ignore << file
      end

      def unignore

      end
    end
  end
end
