require 'sysmoon/ipc/data/hashable'

module Sysmoon
  module IPC
    module Data
      class File
        include Hashable
        extend Unhashable

        module Action
          MODIFY = :modify # File was modified
          DELETE = :delete # File was deleted
          MOVED_TO = :moved_to # File was renamed
          CREATE = :create # File was created
        end

        attr_reader :name, :mode, :touched_at, :action

        def initialize(params)
          @name = params[:name].freeze
          @mode = params[:mode].freeze
          @touched_at = params[:touched_at].freeze
          @action = parse_action(params[:action]).freeze
        end

        private

        def parse_action(action)
          case action.to_s
          when /modify/i
            result = Action::MODIFY
          when /delete/i
            result = Action::DELETE
          when /moved_to/i
            result = Action::MOVED_TO
          when /create/i
            result = Action::CREATE
          end

          result
        end
      end
    end
  end
end
