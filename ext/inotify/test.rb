#!/usr/bin/env ruby
require "./inotify"

a = Inotify.new

# Asserting we don't get any errors on method calls
puts a.add_watch('/etc/test1', Inotify::IN_ALL_EVENTS)
puts a.add_watch('/etc/environment', Inotify::IN_ALL_EVENTS)
puts a.add_watch('/etc/exports', Inotify::IN_ALL_EVENTS)

puts a.rm_watch('/etc/test1')
puts a.rm_watch('/etc/environment')
puts a.rm_watch('/etc/exports')
