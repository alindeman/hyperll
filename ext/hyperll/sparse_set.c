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
  uint32_t *svals = set->values;
  int ssize = set->size;
  uint32_t *ovals = other->values;
  int osize = other->size;

  int capacity = set->capacity;
  uint32_t *values = (uint32_t*)calloc(capacity, sizeof(uint32_t));

  // s tracks svals, o tracks ovals, size tracks values
  int s = 0, o = 0, size = 0;
  while (s < ssize || o < osize) {
    // Check that we don't grow over capacity
    if (size >= capacity) {
      free(values);
      return -1;
    }

    if (o >= osize) {
      values[size++] = svals[s++];
    } else if (s >= ssize) {
      values[size++] = ovals[o++];
    } else {
      int sval = svals[s];
      int oval = ovals[o];

      if (sparse_set_sparse_index(sval) == sparse_set_sparse_index(oval)) {
        values[size++] = sval < oval ? sval : oval;
        s++;
        o++;
      } else if (sval < oval) {
        values[size++] = sval;
        s++;
      } else {
        values[size++] = oval;
        o++;
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
