require 'evesync/log'
require 'evesync/handler/package'
require 'evesync/handler/file'
require 'evesync/ipc/client'

module Evesync

  # Handles package changes, sent via Package class and queue
  # Sends messages to evedatad and available evehands.
  #
  # [See]
  #     - *Evesync::Trigger::File*
  #     - *Evesync::Trigger::Package*
  #
  # [Handlers available:]
  #   - *Evesync::Handler::Package*
  #   - *Evesync::Handler::File*
  #
  # = Example:
  #
  #   handler = Evesync::Handler.new(queue)
  #   Evesync::IPC::Server.new(
  #     :proxy => handler,
  #     ...
  #   )
  #
  # = Example call:
  #
  #   Evesync::IPC::Client.new(
  #     :port => :evehand
  #   ).handle(IPC::Data::Package.new(
  #     :name => 'tree',
  #     :version => '0.0.1',
  #     :command => :install
  #   )
  #
  # = TODO:
  #
  #   * Make anoter daemon\Thread to search for available
  #     evehands daemons
  #   * Delegate +handle+ to another daemon if not found
  class Handler
    def initialize
      @package_handler = Handler::Package.new
      @files_handler = Handler::File.new
      @monitor = IPC::Client.new(
        port: :evemond
      )
      @database = IPC::Client.new(
        port: :evedatad
      )
      Log.debug('Handler initialization done!')
    end

    def handle(message)
      Log.info "Handler triggered with: #{message}"

      handler = if message.is_a? IPC::Data::Package
                  @package_handler
                elsif message.is_a? IPC::Data::File
                  @files_handler
                else
                  Log.error('Handler: unknown message type')
                  nil
                end
      return unless handler

      @monitor.ignore(message)

      # TODO: add PackageManagerLock exception
      # FIXME: package manger may be locked
      # Add sleep and ones again try if PackageManagerLock
      # exception is cought
      handler.handle(message) || @monitor.unignore(message)
      @database.save(message)

      true
    end

    # For syncing and other remove db access
    def events
      @database.events
    end

    def messages(*args)
      @database.messages(*args)
    end
  end
end
