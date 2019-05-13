require 'evesync/trigger/base'
require 'evesync/ipc/data/package'

module Evesync
  class Trigger
    class Package
      include Trigger::Base

      def initialize(params)
        @ignore = []
        @db = params[:db]
        @remotes = params[:remotes]
      end

      def data_class
        IPC::Data::Package
      end
    end
  end
end
