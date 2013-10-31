#include <stdio.h>
#include "hyperll.h"
#include "varint.h"

extern VALUE rb_mHyperll;
VALUE rb_cDeltaBytes;

static VALUE rb_delta_bytes_compress(VALUE self, VALUE rvalues) {
  int rlen = RARRAY_LEN(rvalues);

  // up to 5 bytes per entry plus one for length
  uint32_t *bytes = (uint32_t*)calloc(5 * (rlen + 1), sizeof(uint32_t));
  int offset = varint_write_unsigned(rlen, bytes);

  uint32_t previous = 0;
  for (int i = 0; i < rlen; i++) {
    uint32_t value = NUM2ULONG(rb_ary_entry(rvalues, i));
    offset += varint_write_unsigned(value - previous, bytes + offset);
    previous = value;
  }

  VALUE rary = rb_ary_new2(offset);
  for (int i = 0; i < offset; i++) {
    rb_ary_push(rary, ULONG2NUM(bytes[i]));
  }
  free(bytes);

  return rary;
}

static VALUE rb_delta_bytes_uncompress(VALUE self, VALUE rbytes) {
  // copy to a native array
  int rlen = RARRAY_LEN(rbytes);
  uint32_t *bytes = (uint32_t*)calloc(rlen, sizeof(uint32_t));
  for (int i = 0; i < rlen; i++) {
    bytes[i] = NUM2ULONG(rb_ary_entry(rbytes, i));
  }

  int offset = 0;
  int len = 0;
  int size = varint_read_unsigned(bytes, rlen, &len);
  if (len == -1) {
    rb_raise(rb_eRuntimeError, "invalid variable length integer");
    goto error;
  }
  offset += len;

  VALUE rary = rb_ary_new2(size);

  uint32_t previous = 0;
  for (int i = 0; i < size; i++) {
    uint32_t next = varint_read_unsigned(bytes + offset, rlen - offset, &len);
    if (len == -1) {
      rb_raise(rb_eRuntimeError, "invalid variable length integer");
      goto error;
    }
    offset += len;

    rb_ary_push(rary, ULONG2NUM(previous + next));
    previous += next;
  }

  free(bytes);
  return rary;
error:
  free(bytes);
  return Qnil;
}

void Init_hyperll_delta_bytes(void) {
  rb_cDeltaBytes = rb_define_class_under(rb_mHyperll, "DeltaBytes", rb_cObject);

  rb_define_singleton_method(rb_cDeltaBytes, "compress", rb_delta_bytes_compress, 1);
  rb_define_singleton_method(rb_cDeltaBytes, "uncompress", rb_delta_bytes_uncompress, 1);
}
