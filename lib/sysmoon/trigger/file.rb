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
        @@data_class = IPC::Data::File
      end
    end
  end
end
