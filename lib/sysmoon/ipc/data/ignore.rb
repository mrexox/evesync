require 'sysmoon/ipc/data/hashable'

module Sysmoon
  module IPC
    module Data
      class Ignore
        include Hashable
        extend Unhashable

        attr_reader :subject

        def initialize(params)
          @subject = params[:subject]
        end

        def to_s
          "Ignoring: #{@subject}"
        end
      end
    end
  end
end
