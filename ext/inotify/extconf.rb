require 'mkmf'
extension_name = 'inotify'

have_header('sys/inotify.h')
$CFLAGS += " -std=c99 -Wpedantic "
create_makefile(extension_name)
