#include "wd_list.h"
#include <stdlib.h>
#include <string.h>

int find_matched_node(struct wd_list* head, char* filename, struct wd_list* result);

struct wd_list* wd_list_create(int wd, char* filename)
{
    struct wd_list* new = (struct wd_list*)malloc(sizeof(struct wd_list));
    if (new == NULL) {
	return NULL;		/* Handle it yourself */
    }

    new->wd = wd;
    new->filename = filename;
    new->next = NULL;
    return new;
}

int wd_list_add(struct wd_list* head, struct wd_list* node)
{
    if (head == NULL) {
	return HEAD_IS_NULL;
    }

    if (node == NULL) {
	return NODE_IS_NULL;
    }

    /* Iterating through the list till the last */
    struct wd_list* iter = head;
    while (iter->next != NULL) {
	iter = iter->next;
    }

    iter->next = node;
    return 0;
}

/* Not a strange logic, but finding prematched node is more useful */
struct wd_list* find_prematched_node(struct wd_list* head, char* filename, int* result)
{
   if (head == NULL) {
	*result = HEAD_IS_NULL;
	return NULL;
    }

    /* Iterating through all list till the last */
    struct wd_list* iter = head;
    while (iter->next != NULL) {
	if (strcmp(iter->next->filename, filename) == 0) {
	    break;
	}
	iter = iter->next;
    }

    /* The file wasn't in the wd list */
    if (iter == NULL) {
	*result = FILENAME_NOT_WATCHED;
	return NULL;
    }

    /* The file was found in the wd list: it's iter->next->filename */
    *result = 0;
    return iter;
}

/* We will not use head in search */
int wd_list_remove(struct wd_list* head, char* filename)
{
    int err;
    struct wd_list* matched_node;
    struct wd_list* prematched_node;

    prematched_node = find_prematched_node(head, filename, &err);
    if (prematched_node == NULL) {
	return err;
    }

    /* Remove from the list */
    matched_node = prematched_node->next;
    prematched_node->next = matched_node->next;
    //    free(matched_node->filename); /* FIXME delete if causes an error */
    free(matched_node);
    return 0;
}

int wd_list_find(struct wd_list* head, char* filename, int* res)
{
    int err;
    struct wd_list* prematched_node = find_prematched_node(head, filename, &err);
    if (prematched_node == NULL) {
	return err;
    } else {
	return prematched_node->next->wd;
    }
}
