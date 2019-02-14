# TODO: Document me
class UnknownEvent < StandardError
  attr_reader :event

  def initialize(event)
    @event = event
    msg = "Unknown event occure: "\
          "#0x#{event.to_s(16).upcase.rjust(8,'0')}"
    super(msg)
  end
end
