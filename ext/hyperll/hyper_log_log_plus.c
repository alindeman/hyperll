#include <stdio.h>
#include "hyperll.h"
#include "register_set.h"

extern VALUE rb_mHyperll;
VALUE rb_cHyperllp;

const int FORMAT_NORMAL = 0;
const int FORMAT_SPARSE = 1;

typedef struct {
  int format;
  int p;
  int count;
  int sp;
  int sparse_count;
  int sparse_set_threshold;
  double alpha_mm;

  register_set *set;

  unsigned int *sparse_set;
  int sparse_set_length;
} hyperllp;

void hyperllp_free(hyperllp *hllp) {
  if (hllp->set) register_set_free(hllp->set);
  if (hllp->sparse_set) free(hllp->sparse_set);
  free(hllp);
}

void hyperllp_init(hyperllp *hllp, int p, int sp) {
  hllp->p = p;
  hllp->sp = sp;
  hllp->format = hllp->sp ? FORMAT_SPARSE : FORMAT_NORMAL;

  int count = 1 << p;
  hllp->set = ALLOC(register_set);
  register_set_init(hllp->set, count);

  if (sp > 0) {
    hllp->sparse_count = 1 << sp;
    hllp->sparse_set_threshold = (int)(0.75 * count);
    hllp->sparse_set = (unsigned int*)calloc(count, sizeof(unsigned int));
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
  VALUE p, sp, set, sparse_set;
  rb_scan_args(argc, argv, "13", &p, &sp, &set, &sparse_set);

  if (NIL_P(sp)) sp = INT2NUM(0);

  hyperllp *hllp = ALLOC(hyperllp);
  hyperllp_init(hllp, NUM2INT(p), NUM2INT(sp));
  VALUE hllpv = Data_Wrap_Struct(klass, 0, hyperllp_free, hllp);

  if (hllp->p < 4) rb_raise(rb_eArgError, "p must be >= 4");
  if (hllp->sp >= 32) rb_raise(rb_eArgError, "sp must be < 32");
  if (hllp->sp != 0 && hllp->p > hllp->sp) rb_raise(rb_eArgError, "p must be <= sp");

  return hllpv;
}

static VALUE rb_hyperllp_format(VALUE self) {
  hyperllp *hllp;
  Data_Get_Struct(self, hyperllp, hllp);

  switch(hllp->format) {
    case FORMAT_NORMAL:
      return ID2SYM(rb_intern("normal"));
      break;
    case FORMAT_SPARSE:
      return ID2SYM(rb_intern("sparse"));
      break;
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

void Init_hyperll_hyper_log_log_plus(void) {
  rb_cHyperllp = rb_define_class_under(rb_mHyperll, "HyperLogLogPlus", rb_cObject);

  rb_define_singleton_method(rb_cHyperllp, "new", rb_hyperllp_new, -1);

  rb_define_method(rb_cHyperllp, "format", rb_hyperllp_format, 0);
  rb_define_method(rb_cHyperllp, "format=", rb_hyperllp_format_set, 1);
  rb_define_method(rb_cHyperllp, "p", rb_hyperllp_p, 0);
  rb_define_method(rb_cHyperllp, "sp", rb_hyperllp_sp, 0);
}
