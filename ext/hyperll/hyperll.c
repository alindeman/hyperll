#include "hyperll.h"

VALUE rb_mHyperll;

void Init_hyperll(void) {
  rb_mHyperll = rb_define_module("Hyperll");

  Init_hyperll_register_set();
}
