require 'sysmoon/log'
require 'sysmoon/handler/package'
require 'sysmoon/handler/files'

module Sysmoon
  module Handler

    # Changes handler for syshand daemon
    # The code for handling is in particular classes
    #
    # [Handlers available:]
    #  - Sysmoon::Handler::Package
    #  - Sysmoon::Handler::Files
    #
    # = TODO:
    #  * Delegate +handle+ to another daemon if not found
    #
    class Changes
      def initialize
        @package_handler = Package.new
        @files_handler = Files.new
        @sysmoon = IPC::Client.new(
          :port => :sysmoond
        )
        Log.debug('Changes handler initialized')
      end

      def handle(message)
        Log.info "#{self.class.name} called: #{message}"

        @sysmoon.ignore(message)
        if message.is_a? IPC::Data::Package
          @package_handler.handle(message)
        elsif message.is_a? IPC::Data::Files
          @files_handler.handle(message)
        else
          Log.debug('Unknown handler')
        end
      end
    end
  end
end
