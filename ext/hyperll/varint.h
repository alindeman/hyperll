#ifndef __H_VARINT
#define __H_VARINT

// Writes an unsigned varint.
//
// value: value to encode
// bytes: destination buffer. Caller is responsible for the allocation.
//        Must be of size 5.
//
// Returns the count of the bytes that were actually needed to store the varint
int varint_write_unsigned(uint32_t value, uint8_t bytes[]);

// Reads an unsigned varint.
//
// bytes: encoded value
// maxlen: the maximum number of bytes to read
// len: the number of bytes read to reconstruct the varint; -1 if an error
//      occurred
uint32_t varint_read_unsigned(uint8_t bytes[], int maxlen, int *len);

#endif
