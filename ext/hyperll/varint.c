#include "hyperll.h"
#include "varint.h"

extern VALUE rb_mHyperll;
VALUE rb_cVarint;

// Pass a uint32_t[5] array of size 5.
//
// Returns the count of the bytes that were actually needed to store the varint
int varint_write_unsigned(uint32_t value, uint32_t bytes[]) {
  int i = 0;
  while ((value & 0xFFFFFF80) != 0) {
    bytes[i++] = ((value & 0x7F) | 0x80);
    value >>= 7;
  }

  bytes[i++] = (value & 0x7F);
  return i;
}

// Reads an unsigned varint.
//
// maxlen - the maximum size of the byte array, to prevent buffer overruns
// len - the number of bytes read to reconstruct the varint; -1 if an error
//       occurred
uint32_t varint_read_unsigned(uint32_t bytes[], int maxlen, int *len) {
  uint32_t value, i, b;
  value = i = b = 0;

  while (((b = bytes[i]) & 0x80) != 0) {
    value |= (b & 0x7F) << (i * 7);
    i++;

    if (i >= maxlen) {
      *len = -1;
      return 0;
    }
  }

  value |= (b << (i * 7));
  *len = (i + 1);
  return value;
}

static VALUE rb_varint_read_unsigned_var_int(VALUE klass, VALUE rbytes) {
  int rlen = RARRAY_LEN(rbytes);
  int maxlen = (rlen > 5) ? 5 : rlen;

  uint32_t bytes[5];
  for (int i = 0; i < maxlen; i++) {
    bytes[i] = NUM2ULONG(rb_ary_entry(rbytes, i));
  }

  int len = 0;
  uint32_t value = varint_read_unsigned(bytes, maxlen, &len);

  if (len == -1) {
    rb_raise(rb_eRuntimeError, "Variable length quantity is too long");
    return Qnil;
  }

  // Discard elements that were used to retrieve the value
  for (int i = 0; i < len; i++) {
    rb_ary_shift(rbytes);
  }
  return ULONG2NUM(value);
}

static VALUE rb_varint_write_unsigned_var_int(VALUE klass, VALUE value) {
  VALUE rbytes = rb_ary_new2(5);

  uint32_t bytes[5];
  int len = varint_write_unsigned(NUM2ULONG(value), bytes);
  for (int i = 0; i < len; i++) {
    rb_ary_push(rbytes, ULONG2NUM(bytes[i]));
  }

  return rbytes;
}

void Init_hyperll_varint(void) {
  rb_cVarint = rb_define_class_under(rb_mHyperll, "Varint", rb_cObject);

  rb_define_singleton_method(rb_cVarint, "read_unsigned_var_int", rb_varint_read_unsigned_var_int, 1);
  rb_define_singleton_method(rb_cVarint, "write_unsigned_var_int", rb_varint_write_unsigned_var_int, 1);
}
