#include "hyperll.h"

extern VALUE rb_mHyperll;
VALUE rb_cVarint;

static VALUE rb_varint_read_unsigned_var_int(VALUE klass, VALUE bytes) {
  uint32_t value, i, b;
  value = i = b = 0;

  while (((b = NUM2ULONG(rb_ary_shift(bytes))) & 0x80) != 0) {
    value |= (b & 0x7F) << i;
    i += 7;

    if (i > 35) {
      rb_raise(rb_eRuntimeError, "Variable length quantity is too long");
      return Qnil;
    }
  }

  return ULONG2NUM(value | (b << i));
}

static VALUE rb_varint_write_unsigned_var_int(VALUE klass, VALUE value) {
  VALUE bytes = rb_ary_new2(5);

  uint32_t v = NUM2ULONG(value);
  while ((v & 0xFFFFFF80) != 0) {
    rb_ary_push(bytes, ULONG2NUM((v & 0x7F) | 0x80));
    v >>= 7;
  }

  rb_ary_push(bytes, ULONG2NUM(v & 0x7F));
  return bytes;
}

void Init_hyperll_varint(void) {
  rb_cVarint = rb_define_class_under(rb_mHyperll, "Varint", rb_cObject);

  rb_define_singleton_method(rb_cVarint, "read_unsigned_var_int", rb_varint_read_unsigned_var_int, 1);
  rb_define_singleton_method(rb_cVarint, "write_unsigned_var_int", rb_varint_write_unsigned_var_int, 1);
}
