#ifndef FSMOON_WD_LIST
#define FSMOON_WD_LIST


#define WD_NOT_FOUND		-1
#define HEAD_IS_NULL		-2
#define NODE_IS_NULL		-3
#define FILENAME_NOT_WATCHED	-4

/* This is helper wd_list struct, which is
 * a simple ordered one-way list.
 * In this design the HEAD is an empty node, so
 * it does not store any value.
 */

struct wd_list {
    int wd;
    char* filename;
    struct wd_list* next;
};

struct wd_list* wd_list_create(int wd, char* filename);
int wd_list_add(struct wd_list* head, struct wd_list* node);
int wd_list_remove(struct wd_list* head, char* filename);
int wd_list_find(struct wd_list* head, char* filename, int* res);
#endif
