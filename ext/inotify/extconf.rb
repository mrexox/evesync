require 'mkmf'
extension_name = 'inotify'

have_header('sys/inotify.h')
$CFLAGS << %[ -std=gnu99 ]
create_makefile(extension_name)
