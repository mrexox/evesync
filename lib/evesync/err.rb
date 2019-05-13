# TODO: move to a err directory
module Evesync
  module Err

    # Base Evesync error class.
    # Using it as a base for all Evesync exceptions.
    #
    # = Example:
    #  class MyError < Evesync::Err::Base
    #    def initialize(message, *args)
    #      super(message)
    #      ...
    #    end
    #    ...
    #  end
    class Base < RuntimeError
      def initialize(message)
        super(message)
      end
    end

    class SaveError < Base
    end
  end
end
