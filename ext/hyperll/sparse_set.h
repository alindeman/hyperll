#ifndef __H_SPARSE_SET
#define __H_SPARSE_SET

#include <stdint.h>

typedef struct {
  int capacity;
  int size;
  uint32_t *values;
} sparse_set;

void sparse_set_init(sparse_set *set, int capacity);
int sparse_set_cardinality(sparse_set *set);

// Merges two sparse sets together.
//
// Returns 0 on success; -1 if the sparse set would grow too large
int sparse_set_merge(sparse_set *set, sparse_set *other);

uint32_t sparse_set_sparse_index(uint32_t k);
void sparse_set_free(sparse_set *set);

#endif
