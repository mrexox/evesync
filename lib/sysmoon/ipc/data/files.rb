require 'sysmoon/ipc_data/hashable'

module Sysmoon
  class Files
    include Hashable
    extend Unhashable

    module Action
      MODIFY = :modify # File was modified
      DELETE = :delete # File was deleted
      RENAME = :rename # File was renamed
      ATTRIB = :attrib # Attributes (owner, mod...) changed
    end

    attr_reader :name, :mod, :touched_at, :action

    def initialize(params)
      @name = params[:name].freeze
      @mod = params[:mod].freeze
      @touched_at = params[:touched_at].freeze
      @action = parse_action(params[:action]).freeze
    end

    private

    def parse_action(action)
      case action
      when /modify/i
        result = Action::MODIFY
      when /delete/i
        result = Action::DELETE
      when /rename/i
        result = Action::RENAME
      when /attrib/i
        result = Action::ATTRIB
      end

      result
    end
  end
end
