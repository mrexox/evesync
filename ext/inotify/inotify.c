#include "ruby.h"
#include <sys/inotify.h> 

/* Definitions */
void Inotify_initialize(VALUE);
void add_file(VALUE);
VALUE run(VALUE, VALUE);

/* static const rb_data_type_t inotify_wrapper = { */
/* 	.wrap_struct_name = "foo", */
/* 	.function = { */
/* 		.dmark = NULL, */
/* 		.dfree = foo_free, */
/* 		.dsize = foo_size, */
/* 	}, */
/* 	.data = NULL, */
/* 	.flags = RUBY_TYPED_FREE_IMMEDIATELY, */
/* }; */


/* Code */
void Init_inotify()
{
    VALUE Inotify = rb_define_class("Inotify", rb_cObject);
    // Consts from inotify.h
    rb_define_const(Inotify, "IN_ACCESS", INT2NUM(IN_ACCESS));
    rb_define_const(Inotify, "IN_MODIFY", INT2NUM(IN_MODIFY));
    rb_define_const(Inotify, "IN_ATTRIB", INT2NUM(IN_ATTRIB));
    rb_define_const(Inotify, "IN_CLOSE_WRITE", INT2NUM(IN_CLOSE_WRITE));
    rb_define_const(Inotify, "IN_CLOSE_NOWRITE", INT2NUM(IN_CLOSE_NOWRITE));
    rb_define_const(Inotify, "IN_CLOSE", INT2NUM(IN_CLOSE));
    rb_define_const(Inotify, "IN_OPEN", INT2NUM(IN_OPEN));
    rb_define_const(Inotify, "IN_MOVED_FROM", INT2NUM(IN_MOVED_FROM));
    rb_define_const(Inotify, "IN_MOVED_TO", INT2NUM(IN_MOVED_TO));
    rb_define_const(Inotify, "IN_MOVE",	INT2NUM(IN_MOVE));
    rb_define_const(Inotify, "IN_CREATE", INT2NUM(IN_CREATE));
    rb_define_const(Inotify, "IN_DELETE", INT2NUM(IN_DELETE));
    rb_define_const(Inotify, "IN_DELETE_SELF", INT2NUM(IN_DELETE_SELF));
    rb_define_const(Inotify, "IN_MOVE_SELF", INT2NUM(IN_MOVE_SELF));
    rb_define_const(Inotify, "IN_UNMOUNT", INT2NUM(IN_UNMOUNT));
    rb_define_const(Inotify, "IN_Q_OVERFLOW", INT2NUM(IN_Q_OVERFLOW));
    rb_define_const(Inotify, "IN_IGNORED", INT2NUM(IN_IGNORED));

    rb_define_const(Inotify, "IN_CLOSE", INT2NUM(IN_CLOSE));
    rb_define_const(Inotify, "IN_MOVE", INT2NUM(IN_MOVE));
    rb_define_const(Inotify, "IN_ONLYDIR", INT2NUM(IN_ONLYDIR));
    rb_define_const(Inotify, "IN_DONT_FOLLOW", INT2NUM(IN_DONT_FOLLOW));
    rb_define_const(Inotify, "IN_EXCL_UNLINK", INT2NUM(IN_EXCL_UNLINK));
    rb_define_const(Inotify, "IN_MASK_ADD", INT2NUM(IN_MASK_ADD));
    rb_define_const(Inotify, "IN_ISDIR", INT2NUM(IN_ISDIR));
    rb_define_const(Inotify, "IN_ONESHOT", INT2NUM(IN_ONESHOT));
    rb_define_const(Inotify, "IN_ALL_EVENTS", INT2NUM(IN_ALL_EVENTS));

    
    rb_define_methon(Inotify, "initialize", Inotify_initialize, 0);
    rb_define_methon(Inotify, "run", run, 1);
}

/* Initializing which just creates variables and initialize inotify */
void Inotify_initialize(VALUE self)
{
    int intotify_fd;

    inotify_fd = inotify_init();

    if (inotifyFd == -1) {
	rb_raise(rb_eRuntimeError, "Unable to get inotify descriptor");
    }

    
    rb_iv_set(self, "@inotify_fd", INT2NUM(inotify_fd));
}

/* Adds file into the inotify watcher */
void add_file(VALUE self)
{
    
}

/* Starts the for(;;) loop and handles all events with handler */
VALUE run(VALUE self, VALUE handler)
{

}
