#include "hyperll.h"

extern VALUE rb_mHyperll;
VALUE rb_cRegisterSet;

const int LOG2_BITS_PER_WORD = 6;
const int REGISTER_SIZE = 5;

typedef struct {
  int count;
  int size;
  int *values;
} register_set;

static void register_set_free(register_set *set) {
  free(set->values);
  free(set);
}

static VALUE rb_register_set_new(int argc, VALUE *argv, VALUE klass) {
  VALUE count;
  rb_scan_args(argc, argv, "10", &count);

  register_set *set = ALLOC(register_set);
  set->count = FIX2INT(count);

  int bits = set->count / LOG2_BITS_PER_WORD;
  if (bits == 0) {
    set->size = 1;
  } else if ((bits % sizeof(int)) == 0) {
    set->size = bits;
  } else {
    set->size = bits + 1;
  }

  set->values = (int*)calloc(set->size, sizeof(int));

  return Data_Wrap_Struct(klass, 0, register_set_free, set);
}

void Init_hyperll_register_set(void) {
  rb_cRegisterSet = rb_define_class_under(rb_mHyperll, "RegisterSet", rb_cObject);
  rb_define_singleton_method(rb_cRegisterSet, "new", rb_register_set_new, -1);
}
