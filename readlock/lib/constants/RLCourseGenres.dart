// Canonical closed list of course genres.
//
// The set is mirrored in the rlockie format guide and the ReadlockInstructor
// rules, courses MUST tag with 3 to 5 entries from this list, no invented
// genres allowed. Centralising the list in code means the search screen's
// chip row can paint every possible filter even before any course tagged
// with that genre has loaded, instead of deriving the row from whatever
// happens to be on screen and appearing partial to the reader.

const List<String> COURSE_GENRES = [
  'design',
  'psychology',
  'business',
  'technology',
  'self-help',
  'science',
  'philosophy',
  'history',
  'economics',
  'leadership',
  'creativity',
  'productivity',
  'communication',
  'user-experience',
  'product-development',
];
