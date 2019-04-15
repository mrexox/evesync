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

        attr_reader :name, :mode, :action, :timestamp

        def initialize(params)
          @name = params[:name].freeze
          @mode = params[:mode].freeze
          @action = parse_action(params[:action]).freeze
          @timestamp = params[:timestamp] || Time.now.to_f.to_s
          @content = params[:content] || IO.read(@name).freeze if ::File.exist? @name
        end

        def ==(other)
          (@name == other.name) &&
            (@action == other.action) &&
            (@mode == other.mode)
          # timestamps may differ
          # conten comparing may cost too much
        end

        # == Synopsis
        #  The content of a file for remote call. Sends as
        #  a plain text(?), no extra calls between machines.
        #
        # == TODO
        #  * Think about binary data
        #  * Encoding information
        #  * Large file sending
        attr_reader :content

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
