#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include "sparse_set.h"

void sparse_set_init(sparse_set *set, int sm, int capacity) {
  set->sm = sm;
  set->capacity = capacity;
  set->size = 0;
  set->values = (uint32_t*)calloc(set->capacity, sizeof(uint32_t));
}

int sparse_set_cardinality(sparse_set *set) {
  return (int)round(set->sm * log(((double)set->sm) / (set->sm - set->size)));
}

uint32_t sparse_set_sparse_index(uint32_t k) {
  if ((k & 1) == 1) {
    return k >> 7;
  } else {
    return k >> 1;
  }
}

int sparse_set_merge(sparse_set *set, sparse_set *other) {
  uint32_t *values = (uint32_t*)calloc(set->capacity, sizeof(uint32_t));

  // i tracks set->values, j tracks other->values, size tracks values
  int i = 0, j = 0, size = 0;
  while (i < set->size || j < other->size) {
    // Check that we don't grow over capacity
    if (size >= set->capacity) {
      free(values);
      return -1;
    }

    if (j >= other->size) {
      values[size++] = set->values[i++];
    } else if (i >= set->size) {
      values[size++] = other->values[j++];
    } else {
      int sval = set->values[i];
      int oval = other->values[j];

      if (sparse_set_sparse_index(sval) == sparse_set_sparse_index(oval)) {
        values[size++] = sval < oval ? sval : oval;
        i++;
        j++;
      } else if (sval < oval) {
        values[size++] = sval;
        i++;
      } else {
        values[size++] = oval;
        j++;
      }
    }
  }

  free(set->values);
  set->values = values;
  set->size = size;
  return 0;
}

void sparse_set_free(sparse_set *set) {
  free(set->values);
  free(set);
}
