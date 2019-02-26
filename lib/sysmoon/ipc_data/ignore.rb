require 'sysmoon/ipc_data/hashable'

module Sysmoon
  class Ignore
    include Hashable
    extend Unhashable

    def initialize(params)
      @subject = params[:subject]
    end

    def to_s
      "Ignoring: #{@subject}"
    end
  end
end
