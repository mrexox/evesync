require 'json'

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
    @command = parse_command(params[:command]).freeze
  end

  def to_s
    "Package(#{@command.upcase}: #{name}-#{@version})"
  end

  def to_hash
    hash = {}
    self.instance_variables.each do |var|
      hash[var] = self.instance_variable_get var
    end

    hash
  end

  def to_json
    to_hash.to_json
  end

  def self.from_hash(hash)
    params = {}
    hash.each do |key, value|
      if key =~ /^@/
        params[key.sub('@','').to_sym] = value
      end
    end

    self.new(params)
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
