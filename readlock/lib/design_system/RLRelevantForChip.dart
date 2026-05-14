// Relevant-for chip, renders one audience tag from a course's
// "relevant-for" list (designers, investors, anyone, …) as a small 8-bit
// label on a backgroundLight pill. Label is always white.

import 'package:flutter/material.dart';
import 'package:readlock/constants/RLDesignSystem.dart';
import 'package:readlock/constants/RLTypography.dart';

// * Display names, machine key → label shown to the user.
const Map<String, String> RELEVANT_FOR_DISPLAY_NAMES = {
  'designers': 'Designers',
  'product-managers': 'Product Managers',
  'founders': 'Founders',
  'engineers': 'Engineers',
  'writers': 'Writers',
  'marketers': 'Marketers',
  'leaders': 'Leaders',
  'investors': 'Investors',
  'students': 'Students',
  'anyone': 'Anyone',
};

// * Display name helper. Falls back to a "Title Case, hyphens → spaces"
// mapping so unknown tags still render cleanly.
String getRelevantForDisplayName(String key) {
  final String? mapped = RELEVANT_FOR_DISPLAY_NAMES[key];
  final bool hasMapped = mapped != null;

  if (hasMapped) {
    return mapped;
  }

  final String spaced = key.replaceAll('-', ' ');
  final bool isEmpty = spaced.isEmpty;

  if (isEmpty) {
    return spaced;
  }

  return spaced[0].toUpperCase() + spaced.substring(1);
}

class RLRelevantForChip extends StatelessWidget {
  final String relevantForKey;

  const RLRelevantForChip({super.key, required this.relevantForKey});

  @override
  Widget build(BuildContext context) {
    final String label = getRelevantForDisplayName(relevantForKey);

    final BoxDecoration chipDecoration = BoxDecoration(
      color: RLDS.backgroundLight,
      borderRadius: RLDS.borderRadiusSmall,
    );

    final TextStyle pixelTextStyle = RLTypography.pixelLabelStyle.copyWith(color: RLDS.white);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: RLDS.spacing12, vertical: RLDS.spacing8),
      decoration: chipDecoration,
      child: Text(label, style: pixelTextStyle),
    );
  }
}
