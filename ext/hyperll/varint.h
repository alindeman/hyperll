#ifndef __H_VARINT
#define __H_VARINT

int varint_write_unsigned(uint32_t value, uint32_t bytes[]);
uint32_t varint_read_unsigned(uint32_t bytes[], int maxlen, int *len);

#endif
