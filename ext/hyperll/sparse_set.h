#ifndef __H_SPARSE_SET
#define __H_SPARSE_SET

#include <stdint.h>

typedef struct {
  int capacity;
  int size;
  uint32_t *values;
} sparse_set;

void sparse_set_init(sparse_set *set, int capacity);
void sparse_set_free(sparse_set *set);

#endif
