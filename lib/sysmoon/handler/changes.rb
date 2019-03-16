require 'sysmoon/log'
require 'sysmoon/handler/package'
require 'sysmoon/handler/file'
require 'sysmoon/ipc/client'

module Sysmoon
  module Handler

    # Changes handler for syshand daemon
    # The code for handling is in particular classes
    #
    # [Handlers available:]
    #  - Sysmoon::Handler::Package
    #  - Sysmoon::Handler::File
    #
    # = TODO:
    #  * Delegate +handle+ to another daemon if not found
    #
    class Changes
      def initialize
        @package_handler = Handler::Package.new
        @files_handler = Handler::File.new
        @sysmoon = IPC::Client.new(
          :port => :sysmoond
        )
        Log.debug('Changes handler initialized')
      end

      def handle(message)
        Log.info "#{self.class.name} called: #{message}"

        handler = if message.is_a? IPC::Data::Package
                    @package_handler
                  elsif message.is_a? IPC::Data::File
                    @files_handler
                  else
                    Log.error('Unknown handler')
                    nil
                  end
        unless handler
          return
        end
        @sysmoon.ignore(message)
        handler.handle(message) || @sysmoon.unignore(message)

        'Fine'
      end
    end
  end
end
