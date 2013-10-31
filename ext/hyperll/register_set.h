#ifndef __H_REGISTER_SET
#define __H_REGISTER_SET

#include <stdint.h>

typedef struct {
  int count;
  int size;
  uint32_t *values;
} register_set;

void register_set_init(register_set *set, int count);
void register_set_set(register_set *set, int position, uint32_t value);
uint32_t register_set_get(register_set *set, int position);
int register_set_update_if_greater(register_set *set, int position, uint32_t value);
void register_set_merge(register_set *set, register_set *other);
void register_set_free(register_set *set);

#endif
