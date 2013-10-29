#include <stdio.h>
#include "hyperll.h"
#include "register_set.h"
#include "sparse_set.h"

extern VALUE rb_mHyperll;
VALUE rb_cHyperllp;

const int FORMAT_NORMAL = 0;
const int FORMAT_SPARSE = 1;

typedef struct {
  int format;
  int p;
  int count;
  int sp;
  int sparse_set_threshold;
  double alpha_mm;

  register_set *register_set;
  sparse_set *sparse_set;
} hyperllp;

void hyperllp_free(hyperllp *hllp) {
  if (hllp->register_set) register_set_free(hllp->register_set);
  if (hllp->sparse_set) sparse_set_free(hllp->sparse_set);
  free(hllp);
}

void hyperllp_init(hyperllp *hllp, int p, int sp) {
  hllp->p = p;
  hllp->sp = sp;
  hllp->format = hllp->sp ? FORMAT_SPARSE : FORMAT_NORMAL;

  int count = 1 << p;
  hllp->register_set = ALLOC(register_set);
  register_set_init(hllp->register_set, count);

  if (sp > 0) {
    hllp->sparse_set_threshold = (int)(0.75 * count);
    hllp->sparse_set = ALLOC(sparse_set);

    int sparse_capacity = 1 << sp;
    sparse_set_init(hllp->sparse_set, sparse_capacity);
  } else {
    hllp->sparse_set = NULL;
  }

  switch(p) {
    case 4:
      hllp->alpha_mm = 0.673 * count * count;
      break;
    case 5:
      hllp->alpha_mm = 0.697 * count * count;
      break;
    case 6:
      hllp->alpha_mm = 0.709 * count * count;
      break;
    default:
      hllp->alpha_mm = (0.7213 / (1 + 1.079 / count)) * count * count;
  }
}

static VALUE rb_hyperllp_new(int argc, VALUE *argv, VALUE klass) {
  VALUE p, sp, register_set_values, sparse_set_values;
  rb_scan_args(argc, argv, "13", &p, &sp, &register_set_values, &sparse_set_values);

  if (NIL_P(sp)) sp = INT2NUM(0);

  hyperllp *hllp = ALLOC(hyperllp);
  hyperllp_init(hllp, NUM2INT(p), NUM2INT(sp));
  VALUE hllpv = Data_Wrap_Struct(klass, 0, hyperllp_free, hllp);

  if (hllp->p < 4) rb_raise(rb_eArgError, "p must be >= 4");
  if (hllp->sp >= 32) rb_raise(rb_eArgError, "sp must be < 32");
  if (hllp->sp != 0 && hllp->p > hllp->sp) rb_raise(rb_eArgError, "p must be <= sp");

  if (!NIL_P(register_set_values)) {
    Check_Type(register_set_values, T_ARRAY);

    register_set *rset = hllp->register_set;
    if (RARRAY_LEN(register_set_values) == rset->size) {
      for (int i = 0; i < rset->size; i++) {
        rset->values[i] = NUM2UINT(rb_ary_entry(register_set_values, i));
      }
    } else {
      rb_raise(rb_eArgError, "initial register set values is not of the correct size");
    }
  }

  if (!NIL_P(sparse_set_values)) {
    Check_Type(sparse_set_values, T_ARRAY);

    sparse_set *sset = hllp->sparse_set;
    if (RARRAY_LEN(sparse_set_values) <= sset->capacity) {
      sset->size = RARRAY_LEN(sparse_set_values);
      for (int i = 0; i < sset->size; i++) {
        sset->values[i] = NUM2UINT(rb_ary_entry(sparse_set_values, i));
      }
    } else {
      rb_raise(rb_eArgError, "initial sparse set values have too many values");
    }
  }

  return hllpv;
}

static VALUE rb_hyperllp_format(VALUE self) {
  hyperllp *hllp;
  Data_Get_Struct(self, hyperllp, hllp);

  switch(hllp->format) {
    case FORMAT_NORMAL:
      return ID2SYM(rb_intern("normal"));
    case FORMAT_SPARSE:
      return ID2SYM(rb_intern("sparse"));
  }

  return Qnil;
}

static VALUE rb_hyperllp_format_set(VALUE self, VALUE format) {
  Check_Type(format, T_SYMBOL);

  hyperllp *hllp;
  Data_Get_Struct(self, hyperllp, hllp);

  if (format == ID2SYM(rb_intern("normal"))) {
    hllp->format = FORMAT_NORMAL;
  } else if (format == ID2SYM(rb_intern("sparse"))) {
    hllp->format = FORMAT_SPARSE;
  }

  return format;
}

static VALUE rb_hyperllp_p(VALUE self) {
  hyperllp *hllp;
  Data_Get_Struct(self, hyperllp, hllp);

  return INT2NUM(hllp->p);
}

static VALUE rb_hyperllp_sp(VALUE self) {
  hyperllp *hllp;
  Data_Get_Struct(self, hyperllp, hllp);

  return INT2NUM(hllp->sp);
}

static VALUE rb_hyperllp_cardinality(VALUE self) {
  hyperllp *hllp;
  Data_Get_Struct(self, hyperllp, hllp);

  switch(hllp->format) {
    case FORMAT_NORMAL:
      return INT2NUM(0);
    case FORMAT_SPARSE:
      return INT2NUM(sparse_set_cardinality(hllp->sparse_set));
  }

  return INT2NUM(0);
}

void Init_hyperll_hyper_log_log_plus(void) {
  rb_cHyperllp = rb_define_class_under(rb_mHyperll, "HyperLogLogPlus", rb_cObject);

  rb_define_singleton_method(rb_cHyperllp, "new", rb_hyperllp_new, -1);

  rb_define_method(rb_cHyperllp, "format", rb_hyperllp_format, 0);
  rb_define_method(rb_cHyperllp, "format=", rb_hyperllp_format_set, 1);
  rb_define_method(rb_cHyperllp, "p", rb_hyperllp_p, 0);
  rb_define_method(rb_cHyperllp, "sp", rb_hyperllp_sp, 0);
  rb_define_method(rb_cHyperllp, "cardinality", rb_hyperllp_cardinality, 0);
}
