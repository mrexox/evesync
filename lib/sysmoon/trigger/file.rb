require 'sysmoon/trigger/base'
require 'sysmoon/ipc/data/file'

module Sysmoon
  class Trigger
    class File
      include Base

      def initialize(params)
        @ignore = []
        @db = params[:db]
        @remotes = params[:remotes]
      end

      def process(file_message)
        if ignore?(file_message)
          unignore(file_message)
          false
        else
          if save_to_db(@db, file_message)
            send_to_remotes(@remotes, file_message)
            true
          end
        end
      end

      def ignore(file)
        @ignore << file if
          file.is_a? IPC::Data::File
      end

      def unignore(file)
        @ignore.delete_if { |f| f == file }
      end

      def ignore?(file)
        Log.debug("File ignore aray: #{@ignore}")
        @ignore.find { |f| f == file }
      end
    end
  end
end
