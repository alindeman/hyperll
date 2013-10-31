#ifndef __H__HYPERLL
#define __H__HYPERLL

#include <ruby.h>
#ifndef HAVE_RUBY_ENCODING_H
#error "Hyperll requires Ruby 1.9+ to build"
#else
#include <ruby/encoding.h>
#endif

// Initialization functions
void Init_hyperll_register_set(void);
void Init_hyperll_hyper_log_log_plus(void);
void Init_hyperll_varint(void);
void Init_hyperll_delta_bytes(void);

#endif
