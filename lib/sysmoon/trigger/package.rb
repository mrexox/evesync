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
        @data_class = IPC::Data::Package
      end

      def process(package_message)
        if ignore?(package_message)
          unignore(package_message)
          false
        else
          if save_to_db(@db, package_message)
            send_to_remotes(@remotes, package_message)
            true
          end
        end
      end

      def ignore(package)
        @ignore << package if
          package.is_a? @data_class
      end

      def unignore(package)
        @ignore.delete_if { |p| p == package }
      end

      private

      def ignore?(package)
        Log.debug("Package ignore aray: #{@ignore}")
        @ignore.find { |p| p == package }
      end

    end
  end
end
