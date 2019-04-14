# TODO: move to a err directory
module Sysmoon
  module Err
    # = Synopsis:
    #
    #   Base Sysmoon error class.
    #   Using it as a base for all Sysmoon exceptions.
    #
    # = Example:
    #  class MyError < Sysmoon::Err::Base
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
