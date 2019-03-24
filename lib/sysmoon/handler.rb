require 'sysmoon/log'
require 'sysmoon/handler/package'
require 'sysmoon/handler/file'
require 'sysmoon/ipc/client'

module Sysmoon

  # = Synopsis:
  #
  #   Handles package changes, sent via Package class and queue
  #   Sends messages to sysdatad and available syshands.
  # [See]
  #     - *Sysmoon::Trigger::File*
  #     - *Sysmoon::Trigger::Package*
  #
  # [Handlers available:]
  #   - *Sysmoon::Handler::Package*
  #   - *Sysmoon::Handler::File*
  #
  # = Example:
  #
  #   handler = Sysmoon::Handler.new(queue)
  #   Sysmoon::IPC::Server.new(
  #     :proxy => handler,
  #     ...
  #   )
  #
  # = Example call:
  #
  #   Sysmoon::IPC::Client.new(
  #     :port => :syshand
  #   ).handle(IPC::Data::Package.new(
  #     :name => 'tree',
  #     :version => '0.0.1',
  #     :command => :install
  #   )
  #
  # = TODO:
  #
  #   * Make anoter daemon\Thread to search for available
  #     syshands daemons
  #   * Delegate +handle+ to another daemon if not found
  class Handler

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

      # TODO: add PackageManagerLock exception
      # FIXME: package manger may be locked
      # Add sleep and ones again try if PackageManagerLock
      # exception is cought
      handler.handle(message) || @sysmoon.unignore(message)

      'Fine'
    end
  end
end
