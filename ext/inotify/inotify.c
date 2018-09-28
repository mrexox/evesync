#include "ruby.h"
#include "wd_list.h"
#include <sys/inotify.h> 

#define BUF_LEN     ( 1024 * ( EVENT_SIZE + 16 ) )

/* Definitions */
VALUE Inotify_initialize(VALUE self);
VALUE add_watch(VALUEself , VALUE filename);
VALUE rm_watch(VALUE self, VALUE filename);
VALUE run(VALUE self, VALUE);

/* rb_data_type_t helpers */
VALUE wd_list_alloc(VALUE self);
void wd_list_free(void* data);
size_t wd_list_size(const void* data);
void wd_check_errors(int res);

/* wd_list -> ruby data type */
static const rb_data_type_t wd_list_type = {
	.wrap_struct_name = "wd_list",
	.function = {
		.dmark = NULL,
		.dfree = wd_list_free,
		.dsize = wd_list_size,
	},
	.data = NULL,
	.flags = RUBY_TYPED_FREE_IMMEDIATELY,
};

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

    
    rb_define_method(Inotify, "initialize", Inotify_initialize, 0);
    rb_define_method(Inotify, "add_watch", add_watch, 1);
    rb_define_method(Inotify, "rm_watch", rm_watch, 1);
    rb_define_method(Inotify, "run", run, 1);
}

/* Initializing which just creates variables and initialize inotify */
VALUE Inotify_initialize(VALUE self)
{
    /* Initialize inotify */

    int intotify_fd;

    inotify_fd = inotify_init();

    if (inotifyFd == -1) {
	rb_raise(rb_eRuntimeError, "Unable to get inotify descriptor");
    }

    
    rb_iv_set(self, "@inotify_fd", INT2NUM(inotify_fd));

    /* Initialize wd_list */
    
    struct wd_list* head;
    TypedData_Get_Struct(self, struct wd_list, &wd_list_type, head);
    /* head is not used in search */
    head->wd = inotify_fd;	/* Feature we may need */
    head->filename = NULL;

    return self;
}

/* Adds file into the inotify watcher, returns wd */
VALUE add_watch(VALUE self, VALUE filename)
{
    /* Getting inotify's file descriptor */
    VALUE rb_inotify_fd = rb_iv_get(self, "@inotify_fd");
    int inotify_fd = NUM2INT(rb_inotify_fd);

    /* Add file to watched */
    int wd;
    char* cstr_file = StringValueCStr(filename);
    wd = inotify_add_watch(inotify_fd, cstr_file, IN_ALL_EVENTS);
    if (wd == -1) {
	rb_raise(rb_eRuntimeError, "Unable to add file to the watched");
    }

    /* Save wd */
    struct wd_list* node = wd_list_create(wd, filename);
    if (node == NULL) {
	rb_raise(rb_eRuntimeError, "Couldn't create a node. Not enough memory");
    }
    
    struct wd_list* head;
    TypedData_Get_Struct(self, struct wd_list, &wd_list_type, head);
    res = wd_list_add(head, cstr_file, node);

    wd_check_errors(res);
    
    return INT2NUM(wd);
}

VALUE rm_watch(VALUE self, VALUE filename)
{
    /* Getting inotify's file descriptor */
    VALUE rb_inotify_fd = rb_iv_get(self, "@inotify_fd");
    int inotify_fd = NUM2INT(rb_inotify_fd);

    /* Get wd by filename */
    struct wd_list* head;
    TypedData_Get_Struct(self, struct wd_list, &wd_list_type, head);
    char* cstr_filename = StringValueCStr(filename);
    int file_wd = wd_list_find(head, cstr_filename);

    wd_check_errors(file_wd);
    wd_list_remove(head, cstr_filename);
    
    /* Removing file from watched */
    int wd;
    wd = inotify_rm_watch(inotify_fd, file_wd);
    if (wd == -1) {
	rb_raise(rb_eRuntimeError, "Unable to remove file from watched");
    }
    return INT2NUM(wd);
}

/* Starts the for(;;) loop and handles all events with handler.
 * 
 * Handler is a block or a proc. It recieves a filename's wd 
 * and an event of type IN_*.
 *
 * All the logic will come with ruby code.
 */
VALUE run(VALUE self, VALUE handler)
{
    /* Getting inotify's file descriptor */
    VALUE rb_inotify_fd = rb_iv_get(self, "@inotify_fd");
    int inotify_fd = NUM2INT(rb_inotify_fd);

    /* Helper vars */
    size_t num_read;
    char buf[BUF_LEN] __attribute__ ((aligned(8));
    
    for (;;) {
	num_read = read(inotify_fd, buf, BUF_LEN);
	if (num_read == -1) {
	    rb_raise(rb_eRuntimeError, "Reading from inotify file descriptor returned -1");
	}

	/* Processing read data */
	
	for (char* p = buf; b < buf + num_read; ) {
	    event = (struct inotify_event*) p;
	    /* TODO handle the event */
	    p += sizeof(struct inotify_event*) + event->len;
	}
    }
}


/* Functions for wd_list_type */

/* Allocating function */
VALUE wd_list_alloc(VALUE self)
{
    /* allocate */
    struct wd_list* data = (struct wd_list*) malloc(sizeof(struct wd_list));
    
    /* wrap */
    return TypedData_Wrap_Struct(self, &wd_list_type, data);
}


/* Destroying frees all resources using this function */
void wd_list_free(void* data)
{
    struct wd_list* iter = (struct wd_list*) data;
    struct wd_list* prev;

    if (iter == NULL) {
	return;
    }
    
    while (iter->next != NULL) {
	prev = iter;
	iter = iter->next;
	free(prev->filename);	/* FIXME delete if causes an error */
	free(prev);
    }
    free(iter->filename);	/* FIXME delete if causes an error */
    free(iter);
}

/* Counts the size of a structure */
size_t wd_list_size(const void* data)
{
    size_t total = 0;
    struct wd_list* head = (struct wd_list*) data;
    
    if (head == NULL) {
	return 0;
    }

    struct wd_list* iter = head;
    while (iter->next != NULL) {
	if (iter->filename != NULL) {
	    total += strlen(iter->filename) * sizeof(char);
	}
	total += sizeof(struct wd_list);
	iter = iter->next;
    }
    return total;
}

/* This function checks the return values of functions defined 
 * in wd_list.h
 *
 * It just raises the Ruby exceptions for errors, occured
 * in these functions (we don't want a segmentation fault).
 */
void wd_check_errors(int res)
{
    switch(res) {
    case WD_NOT_FOUND:
	rb_raise(rb_eRuntimeError, "Watch descriptor was not found");
	break;
    case HEAD_IS_NULL:
	rb_raise(rb_eRuntimeError, "Unfortunately wd_list's HEAD wasn't initialized");
	break;
    case NODE_IS_NULL:
	rb_raise(rb_eRuntimeError, "Uninitialized node was to be inserted into wd_list");
	break;
    case FILENAME_NOT_WATCHED:
	/* For this case we may just ignore */
	rb_raise(rb_eRuntimeError, "File is not watching");
	break;
    }
}
