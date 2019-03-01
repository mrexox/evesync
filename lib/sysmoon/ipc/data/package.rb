require 'sysmoon/ipc_data/hashable'

module Sysmoon
  class Package
    include Hashable
    extend Unhashable

    module Command
      INSTALL   = :install
      UPDATE    = :update
      DOWNGRADE = :downgrade
      REMOVE    = :remove
      UNKNOWN   = :unknown
    end

    attr_reader :name, :version, :command

    def initialize(params)
      @name = params[:name].freeze
      @version = params[:version].freeze
      @command = parse_command(params[:command]).freeze
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
