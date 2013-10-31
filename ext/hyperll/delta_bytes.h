#ifndef __H_DELTA_BYTES
#define __H_DELTA_BYTES

// Compress bytes.
//
// bytes: value to compress
// len: length of bytes
// dest: destination buffer for compressed values. Caller is responsible for
//       the allocation. Must be of size 5*len.
//
// Returns the number of bytes written to dest
int delta_bytes_compress(uint32_t values[], int len, uint8_t dest[]);

// Uncompress bytes.
//
// compressed: compressed value
// len: length of compressed
// bytes: destination bufer for uncompressed values. Caller is responsible for
//        the allocation. Must be of size len to be safe.
//
// Returns the number of values written to values; -1 on error
int delta_bytes_uncompress(uint8_t compressed[], int len, uint32_t values[]);

#endif
