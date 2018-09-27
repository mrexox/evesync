#include "ruby.h"

void Init_inotify()
{
    VALUE Inotify = rb_define_class("Inotify", rb_cObject);
    rb_define_methon(Inotify, "add_file", add_file, 0);
}

VALUE add_file(VALUE self)
{
    /* Adds file into the inotify watcher */
}

