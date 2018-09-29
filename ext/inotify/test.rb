#!/usr/bin/env ruby
require "./inotify"

a = Inotify.new
puts a.add_watch('/etc/test1')
puts a.add_watch('/etc/environment')
puts a.add_watch('/etc/exports')
puts a.rm_watch('/etc/test1')
puts a.rm_watch('/etc/environment')
puts a.rm_watch('/etc/exports')
