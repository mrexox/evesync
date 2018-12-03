# :markup: TomDoc
require 'sysmoon/inotify/inotify'
require 'sysmoon/exceptions/unknown_event.rb'

# Public: This package is for inotify communication
#   The file can be suddenly IN_IGNORED
#   So the method to renew the inotify on this file must present
# Example:
#
#   require 'sysmoon/watcher'
#   watcher = Watcher.new
#   watcher.add_file('/etc/environment')
#   watcher.run do |mask, wd, name, cookie|
#     case mask
#     when Watcher::IN_MODIFY
#       puts 'file was modified'
#     when Watcher::IN_DELETE
#       puts 'file was deleted'
#     else
#       puts "Event #{Watcher.event_name(mask)} happened"
#     end
#   end
#
class Watcher < Inotify
  @@events = {
    IN_ACCESS => :accessed,
    IN_MODIFY => :modified,
    IN_ATTRIB => :metadata_changed,
    IN_CLOSE_WRITE => :closed,
    # unwritable file closed, not in current version
    IN_CLOSE_NOWRITE => :closed,
    IN_OPEN => :open,
    IN_MOVED_FROM => :moved_from,
    IN_MOVED_TO => :moved_to,
    IN_CREATE => :created,
    IN_DELETE => :deleted,
    IN_DELETE_SELF => :self_deleted,
    IN_MOVE_SELF => :self_moved,
    IN_IGNORED => :ignored,
    IN_CLOSE => :closed,
    IN_MOVE => :moved,
    IN_ALL_EVENTS => :all_events,
  }
  def event_by_mask(event)
    @@events[event] or raise UnknownEvent.new(event)
  end

  private


end
