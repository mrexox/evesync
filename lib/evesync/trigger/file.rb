require 'evesync/trigger/base'
require 'evesync/ipc/data/file'

module Evesync
  class Trigger
    class File
      include Base

      def initialize(params)
        @ignore = []
        @db = params[:db]
        @remotes = params[:remotes]
      end

      def data_class
        IPC::Data::File
      end
    end
  end
end
