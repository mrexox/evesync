class Package
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
    @command = parse_command(params[:command])
  end

  private

  def parse_command(command)
    case command
    when /^inst\w+$/
      command = Command::INSTALL
    when /^(remove\w*|delete\w*)$/
      command = Command::REMOVE
    when /^(update\w*|upgrade\w*)$/
      command = Command::UPDATE
    when /^downgrade\w*$/
      command = Command::DOWNGRADE
    else
      command = Command::UNKNOWN
    end

    return command.to_s.freeze
  end
end
