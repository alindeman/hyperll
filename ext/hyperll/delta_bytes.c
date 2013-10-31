#include <stdio.h>
#include "hyperll.h"
#include "varint.h"
#include "delta_bytes.h"

extern VALUE rb_mHyperll;
VALUE rb_cDeltaBytes;

int delta_bytes_compress(uint32_t values[], int len, uint8_t dest[]) {
  int offset = 0;
  uint32_t previous = 0;
  for (int i = 0; i < len; i++) {
    uint32_t value = values[i];
    offset += varint_write_unsigned(value - previous, dest + offset);
    previous = value;
  }

  return offset;
}

int delta_bytes_uncompress(uint8_t compressed[], int len, uint32_t values[]) {
  int i = 0;
  int offset = 0;
  uint32_t previous = 0;
  while (offset < len) {
    int offsetlen;
    uint32_t next = varint_read_unsigned(compressed + offset, len - offset, &offsetlen);
    if (offsetlen == -1) return -1;

    offset += offsetlen;
    values[i++] = previous + next;
    previous += next;
  }

  return i;
}

static VALUE rb_delta_bytes_compress(VALUE self, VALUE rvalues) {
  int rlen = RARRAY_LEN(rvalues);

  int offset = 0;
  uint8_t *dest = (uint8_t*)calloc(5 * rlen, sizeof(uint8_t));

  uint32_t previous = 0;
  for (int i = 0; i < rlen; i++) {
    uint32_t value = NUM2ULONG(rb_ary_entry(rvalues, i));
    offset += varint_write_unsigned(value - previous, dest + offset);
    previous = value;
  }

  VALUE rary = rb_ary_new2(offset);
  for (int i = 0; i < offset; i++) {
    rb_ary_push(rary, INT2NUM(dest[i]));
  }
  free(dest);

  return rary;
}

static VALUE rb_delta_bytes_uncompress(VALUE self, VALUE rcompressed) {
  // copy to a native array
  int rlen = RARRAY_LEN(rcompressed);
  uint8_t *compressed = (uint8_t*)calloc(rlen, sizeof(uint8_t));
  for (int i = 0; i < rlen; i++) {
    compressed[i] = (uint8_t)NUM2INT(rb_ary_entry(rcompressed, i));
  }

  int offset = 0;
  int len = 0;

  uint32_t *values = (uint32_t*)calloc(rlen, sizeof(uint32_t));
  int vlen = delta_bytes_uncompress(compressed, rlen, values);
  if (vlen < 0) {
    rb_raise(rb_eRuntimeError, "corrupted values");
    goto error;
  }

  VALUE rary = rb_ary_new2(vlen);
  for (int i = 0; i < vlen; i++) {
    rb_ary_push(rary, ULONG2NUM(values[i]));
  }

  free(compressed);
  free(values);
  return rary;
error:
  free(compressed);
  free(values);
  return Qnil;
}

void Init_hyperll_delta_bytes(void) {
  rb_cDeltaBytes = rb_define_class_under(rb_mHyperll, "DeltaBytes", rb_cObject);

  rb_define_singleton_method(rb_cDeltaBytes, "compress", rb_delta_bytes_compress, 1);
  rb_define_singleton_method(rb_cDeltaBytes, "uncompress", rb_delta_bytes_uncompress, 1);
}
