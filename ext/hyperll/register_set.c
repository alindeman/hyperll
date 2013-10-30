#include "hyperll.h"
#include "register_set.h"

extern VALUE rb_mHyperll;
VALUE rb_cRegisterSet;

const int LOG2_BITS_PER_WORD = 6;
const int REGISTER_SIZE = 5;

void register_set_init(register_set *set, int count) {
  set->count = count;

  int bits = count / LOG2_BITS_PER_WORD;
  if (bits == 0) {
    set->size = 1;
  } else if ((bits % sizeof(int)) == 0) {
    set->size = bits;
  } else {
    set->size = bits + 1;
  }

  set->values = (uint32_t*)calloc(set->size, sizeof(uint32_t));
}

void register_set_set(register_set *set, int position, uint32_t value) {
  int bucket = position / LOG2_BITS_PER_WORD;
  int shift = REGISTER_SIZE * (position - (bucket * LOG2_BITS_PER_WORD));

  set->values[bucket] = (set->values[bucket] & ~(0x1f << shift)) | (value << shift);
}

uint32_t register_set_get(register_set *set, int position) {
  int bucket = position / LOG2_BITS_PER_WORD;
  int shift = REGISTER_SIZE * (position - (bucket * LOG2_BITS_PER_WORD));
  return (uint32_t)(((set->values[bucket] & (0x1f << shift))) >> shift);
}

int register_set_update_if_greater(register_set *set, int position, uint32_t value) {
  int bucket = position / LOG2_BITS_PER_WORD;
  int shift = REGISTER_SIZE * (position - (bucket * LOG2_BITS_PER_WORD));
  uint32_t mask = 0x1f << shift;

  uint64_t cur = set->values[bucket] & mask;
  uint64_t new = value << shift;
  if (cur < new) {
    set->values[bucket] = (uint32_t)((set->values[bucket] & ~mask) | new);
    return 1;
  } else {
    return 0;
  }
}

void register_set_merge(register_set *set, register_set *other) {
  for (int bucket = 0; bucket < set->size; bucket++) {
    int word = 0;
    for (int j = 0; j < LOG2_BITS_PER_WORD; j++) {
      int mask = 0x1f << (REGISTER_SIZE * j);

      int thisVal = (set->values[bucket] & mask);
      int thatVal = (other->values[bucket] & mask);
      word |= (thisVal < thatVal) ? thatVal : thisVal;
    }
    set->values[bucket] = word;
  }
}

void register_set_free(register_set *set) {
  free(set->values);
  free(set);
}

static VALUE rb_register_set_new(int argc, VALUE *argv, VALUE klass) {
  VALUE count, values;
  rb_scan_args(argc, argv, "11", &count, &values);

  register_set *set = ALLOC(register_set);
  register_set_init(set, NUM2INT(count));
  VALUE setv = Data_Wrap_Struct(klass, 0, register_set_free, set);

  if (!NIL_P(values)) {
    Check_Type(values, T_ARRAY);
    if (RARRAY_LEN(values) == set->size) {
      for (int i = 0; i < set->size; i++) {
        set->values[i] = NUM2ULONG(rb_ary_entry(values, i));
      }
    } else {
      rb_raise(rb_eArgError, "initial set of values is not of the correct size");
    }
  }

  return setv;
}

static VALUE rb_register_set_index_set(VALUE self, VALUE position, VALUE value) {
  Check_Type(position, T_FIXNUM);
  Check_Type(value, T_FIXNUM);

  register_set *set;
  Data_Get_Struct(self, register_set, set);
  register_set_set(set, NUM2INT(position), NUM2ULONG(value));

  return Qnil;
}

static VALUE rb_register_set_index_get(VALUE self, VALUE position) {
  Check_Type(position, T_FIXNUM);

  register_set *set;
  Data_Get_Struct(self, register_set, set);
  return UINT2NUM(register_set_get(set, NUM2INT(position)));
}

static VALUE rb_register_set_update_if_greater(VALUE self, VALUE position, VALUE value) {
  Check_Type(position, T_FIXNUM);
  Check_Type(value, T_FIXNUM);

  register_set *set;
  Data_Get_Struct(self, register_set, set);
  int rv = register_set_update_if_greater(set, NUM2INT(position), NUM2ULONG(value));

  return rv ? Qtrue : Qfalse;
}

static VALUE rb_register_set_merge(VALUE self, VALUE other) {
  register_set *set;
  Data_Get_Struct(self, register_set, set);

  register_set *other_set;
  Data_Get_Struct(other, register_set, other_set);
  if (other_set == NULL) {
    rb_raise(rb_eTypeError, "other must be another register set");
    return Qnil;
  }

  register_set_merge(set, other_set);

  return self;
}

static VALUE rb_register_set_each(VALUE self) {
  register_set *set;
  Data_Get_Struct(self, register_set, set);

  for (int i = 0; i < set->count; i++) {
    rb_yield(UINT2NUM(register_set_get(set, i)));
  }

  return self;
}

static VALUE rb_register_set_serialize(VALUE self) {
  register_set *set;
  Data_Get_Struct(self, register_set, set);

  int strsize = set->size * sizeof(int);
  char *str = (char*)malloc(strsize + 1);
  str[strsize] = 0;

  for (int i = 0; i < set->size; i++) {
    int value = set->values[i];
    int offset = i * 4;

    str[offset] = (char)(value >> 24);
    str[offset + 1] = (char)(value >> 16);
    str[offset + 2] = (char)(value >> 8);
    str[offset + 3] = (char)value;
  }

  return rb_str_new(str, strsize);
}

static VALUE rb_register_set_size(VALUE self) {
  register_set *set;
  Data_Get_Struct(self, register_set, set);

  return INT2NUM(set->size);
}

void Init_hyperll_register_set(void) {
  rb_cRegisterSet = rb_define_class_under(rb_mHyperll, "RegisterSet", rb_cObject);
  rb_include_module(rb_cRegisterSet, rb_mEnumerable);

  rb_define_singleton_method(rb_cRegisterSet, "new", rb_register_set_new, -1);

  rb_define_method(rb_cRegisterSet, "[]=", rb_register_set_index_set, 2);
  rb_define_method(rb_cRegisterSet, "[]", rb_register_set_index_get, 1);
  rb_define_method(rb_cRegisterSet, "update_if_greater", rb_register_set_update_if_greater, 2);
  rb_define_method(rb_cRegisterSet, "merge", rb_register_set_merge, 1);
  rb_define_method(rb_cRegisterSet, "each", rb_register_set_each, 0);
  rb_define_method(rb_cRegisterSet, "serialize", rb_register_set_serialize, 0);
  rb_define_method(rb_cRegisterSet, "size", rb_register_set_size, 0);
}
