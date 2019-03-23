require 'sysmoon/trigger/base'
require 'sysmoon/ipc/data/package'

module Sysmoon
  class Trigger
    class Package
      include Base

      def initialize(params)
        @ignore = []
        @db = params[:db]
        @remotes = params[:remotes]
        @@data_class = IPC::Data::Package
      end
    end
  end
end
