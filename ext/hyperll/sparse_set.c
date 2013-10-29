#include <stdlib.h>
#include "sparse_set.h"

void sparse_set_init(sparse_set *set, int capacity) {
  set->capacity = capacity;
  set->size = 0;
  set->values = (uint32_t*)calloc(set->size, sizeof(uint32_t));
}

void sparse_set_free(sparse_set *set) {
  free(set->values);
  free(set);
}
