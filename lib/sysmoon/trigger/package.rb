require 'sysmoon/trigger/base'
require 'sysmoon/ipc/data/package'

module Sysmoon
  class Trigger
    class Package
      include Base

      def intialize(params)
        @ignore = []
        @db = params[:db]
        @remotes = params[:remotes]
      end

      def process(package_message)
        if process_or_ignore(package_message)
          if save_to_db(@db, package_message)
            send_to_remotes(@remotes, package_message)
          end
        else
          false
        end
      end

      def ignore(package)
        Log.debug('Checking if package would be ignored')
        if package.is_a? IPC::Data::Package
          @ignore << package
          Log.debug('Package is ignored')
        else
          Log.debug('Package is not an IPC::Data::Package instance')
        end
      end

      def unignore(package)
        index = find_ignore_index(package)
        @ignore.delete_at(index)
      end

      private

      def process_or_ignore(package)
        Log.debug("Ignore aray: #{@ignore}")
        index = find_ignore_index(package)

        if index != -1
          Log.debug("Igored package #{package}")
          @ignore.delete_at(index)
          return nil
        end

        true
      end

      def find_ignore_index(package)
        @ignore.each_with_index do |ignpkg, i|
          if ignpkg == package
            return i
          end
        end
        -1
      end

    end
  end
end
