# :markup: TomDoc
# Public: Exception, raised on unknown event happened
#
# Examples
#
#   requrie 'unknownevent'
#   event = get_event
#   begin
#     raise UnknownEvent.new event
#   rescue UnknownEvent => e
#     puts e.to_s
#     handle_event(e.event)
#   end
#   ...
#
class UnknownEvent < StandardError
  attr_reader :event

  def initialize(event)
    @event = event
    msg = "Unknown event occure: "\
          "#0x#{event.to_s(16).upcase.rjust(8,'0')}"
    super(msg)
  end
end
