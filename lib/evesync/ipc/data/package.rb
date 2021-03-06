require 'evesync/ipc/data/hashable'

module Evesync
  module IPC
    module Data
      class Package
        include Data::Hashable
        extend Data::Unhashable

        module Command
          INSTALL   = :install
          UPDATE    = :update
          DOWNGRADE = :downgrade
          REMOVE    = :remove
          UNKNOWN   = :unknown
        end

        attr_reader :name, :version, :command, :timestamp

        def initialize(params)
          @name = params[:name].freeze
          @version = params[:version].freeze
          @command = parse_command(params[:command]).freeze
          @timestamp = params[:timestamp] || NTP.timestamp
        end

        def ==(pkg)
          (pkg.name == @name) &&
            (pkg.version == @version) &&
            (pkg.command == @command)
        end

        def to_s
          "Package(#{@command.upcase}: #{name}-#{@version})"
        end

        private

        def parse_command(command)
          cmd = case command
                when /^inst\w+$/
                  Command::INSTALL
                when /^(remove\w*|delete\w*)$/
                  Command::REMOVE
                when /^(update\w*|upgrade\w*)$/
                  Command::UPDATE
                when /^downgrade\w*$/
                  Command::DOWNGRADE
                else
                  Command::UNKNOWN
                end

          cmd.to_s
        end
      end
    end
  end
end
