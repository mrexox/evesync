require 'sysmoon/handler/changes'

module Sysmoon

  # = Synopsis:
  #
  #   Handles package changes, sent via Package class and queue
  #   Sends messages to sysdatad and available syshands
  #
  # = Example:
  #
  #   thread = Sysmoon::Handler::Changes.new(queue).run
  #
  # = TODO:
  #
  #   * Make anoter daemon\Thread to search for available
  #     syshands daemons
  #
  module Handler
  end
end
