// Centralised purchase constants.
//
// Course price is a flat 10 feathers for now. When pricing per-course
// lands, swap this for a lookup keyed by courseId (or a field on the
// course document). All call-sites in PurchaseService and the roadmap
// purchase button read from here.

class PurchaseConstants {
  // App Store Connect product identifiers (iOS auto-renewable subscriptions).
  // Create these in ASC once the subscription group is set up.
  static const String PRODUCT_ID_BEGINNER = 'com.readlock.feathers.beginner';
  static const String PRODUCT_ID_READER = 'com.readlock.feathers.reader';

  // All subscription product IDs queried by StoreKitService on init.
  static const Set<String> SUBSCRIPTION_PRODUCT_IDS = {
    PRODUCT_ID_BEGINNER,
    PRODUCT_ID_READER,
  };

  // Maps each product ID to the number of feathers credited on purchase.
  static const Map<String, int> FEATHERS_PER_PRODUCT = {
    PRODUCT_ID_BEGINNER: 100,
    PRODUCT_ID_READER: 300,
  };

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
