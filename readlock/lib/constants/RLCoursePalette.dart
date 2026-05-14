// The course colour palette, single source of truth shared by:
//   - the roadmap hero (course color → matching book asset + accent)
//   - the relevant-for chips on the hero card
//
// Hex keys match filenames in assets/books/{HEX}.png. `RLCoursePalette.color`
// maps a hex key to its Color; `KNOWN_COURSE_COLORS` is the fast membership
// set used to tell palette colours from arbitrary ones.

import 'package:flutter/material.dart';

class RLCoursePalette {
  static const Color hex6A99D4 = Color(0xFF6A99D4);
  static const Color hex6D7487 = Color(0xFF6D7487);
  static const Color hex72ACAD = Color(0xFF72ACAD);
  static const Color hex78A3ED = Color(0xFF78A3ED);
  static const Color hex8461BD = Color(0xFF8461BD);
  static const Color hex9E7071 = Color(0xFF9E7071);
  static const Color hexC78871 = Color(0xFFC78871);
  static const Color hexC85159 = Color(0xFFC85159);
  static const Color hexCAC7EE = Color(0xFFCAC7EE);
  static const Color hexD0CBD6 = Color(0xFFD0CBD6);
  static const Color hexFAF0A2 = Color(0xFFFAF0A2);
  static const Color hexFFC1E2 = Color(0xFFFFC1E2);

  static const Map<String, Color> byHex = {
    '6A99D4': hex6A99D4,
    '6D7487': hex6D7487,
    '72ACAD': hex72ACAD,
    '78A3ED': hex78A3ED,
    '8461BD': hex8461BD,
    '9E7071': hex9E7071,
    'C78871': hexC78871,
    'C85159': hexC85159,
    'CAC7EE': hexCAC7EE,
    'D0CBD6': hexD0CBD6,
    'FAF0A2': hexFAF0A2,
    'FFC1E2': hexFFC1E2,
  };
}

const Set<String> KNOWN_COURSE_COLORS = {
  '6A99D4',
  '6D7487',
  '72ACAD',
  '78A3ED',
  '8461BD',
  '9E7071',
  'C78871',
  'C85159',
  'CAC7EE',
  'D0CBD6',
  'FAF0A2',
  'FFC1E2',
};

const String COURSE_FALLBACK_COLOR_HEX = '7D5465';
const Color COURSE_FALLBACK_COLOR = Color(0xFF7D5465);

// * Charge bar tile colors, ordered from critical (red) to fully charged (green).
// 7 tiles map to the rental window so the bar reads like a game health meter.
// Changing COURSE_RENTAL_DAYS rescales automatically; the tile count is fixed.
const int CHARGE_BAR_TILE_COUNT = 7;

const List<Color> CHARGE_BAR_TILE_COLORS = [
  Color(0xFFA90015),
  Color(0xFFCE1400),
  Color(0xFFDE5007),
  Color(0xFFED7614),
  Color(0xFFFFA214),
  Color(0xFF47C53A),
  Color(0xFF21983D),
];

// Asset paths, shared so the roadmap hero and every list card that renders
// a course book pull from the same place.
const String COURSE_BOOKS_ASSET_PREFIX = 'assets/books/';
const String COURSE_FALLBACK_ASSET = 'assets/books/FALLBACK.png';
