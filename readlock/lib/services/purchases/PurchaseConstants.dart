// Centralised purchase constants.
//
// Course price is a flat 10 feathers for now. When pricing per-course
// lands, swap this for a lookup keyed by courseId (or a field on the
// course document). All call-sites in PurchaseService and the roadmap
// purchase button read from here.

class PurchaseConstants {
  static const int COURSE_PURCHASE_COST = 10;
}
