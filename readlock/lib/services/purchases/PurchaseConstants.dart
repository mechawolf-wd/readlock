// Centralised purchase constants.
//
// Course price is a flat 10 feathers for now. When pricing per-course
// lands, swap this for a lookup keyed by courseId (or a field on the
// course document). All call-sites in PurchaseService and the roadmap
// purchase button read from here.

class PurchaseConstants {
  static const int COURSE_PURCHASE_COST = 10;

  // Rental window granted on every purchase and on every resurrect.
  static const int COURSE_RENTAL_DAYS = 14;

  // Feathers spent to resurrect an expired course for another rental
  // window. Resurrect is only allowed once the existing entry's expires
  // timestamp has passed.
  static const int COURSE_RESURRECT_COST = 3;

  // Maximum seconds credited to timeSpentReading per session. Anything
  // above this is floored to prevent idle-tab cheating of the feather
  // economy. The display timer still shows the real elapsed time.
  static const int MAX_SESSION_CREDITED_SECONDS = 10 * 60;
}
