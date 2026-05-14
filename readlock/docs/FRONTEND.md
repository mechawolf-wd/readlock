# Frontend Reference

Design system, layout primitives, and UI patterns for the Readlock Flutter app.

## Design System (RLDS)

File: `lib/constants/RLDesignSystem.dart`

### Colors

| Token                   | Hex     | Use                                 |
| ----------------------- | ------- | ----------------------------------- |
| primary                 | #EE4654 | Brand red, nav highlight            |
| info                    | #29B1F4 | Blue accent                         |
| success / markupGreen   | #4ADE80 | Correct answers, green markup spans |
| warning                 | #F9B42C | Amber                               |
| error / markupRed       | #F87171 | Wrong answers, red markup spans     |
| surface                 | #1C1C1E | App background (dark only)          |
| backgroundLight         | #2C2C2E | Sheet/card raised surface           |
| textPrimary / onSurface | #E5E5E5 | Body text                           |
| textSecondary           | #A0A0A0 | Labels, captions                    |
| textMuted               | #5A5A5A | Disabled, hints                     |

### Spacing (multiples of 4)

`spacing0` 0, `spacing4` 4, `spacing8` 8, `spacing12` 12, `spacing16` 16, `spacing20` 20, `spacing24` 24, `spacing32` 32, `spacing40` 40, `spacing48` 48

### Border Radius

| Token                           | Value |
| ------------------------------- | ----- |
| radiusXSmall                    | 4     |
| radiusSmall                     | 12    |
| radiusMedium                    | 16    |
| radiusLarge / modalCornerRadius | 24    |
| radiusCircle                    | 100   |

### Icon Sizes

`iconSmall` 16, `iconMedium` 20, `iconLarge` 24, `iconXLarge` 32, `iconXXLarge` 48

### Animation Durations

| Token                    | ms   | Use                         |
| ------------------------ | ---- | --------------------------- |
| opacityFadeDurationFast  | 200  | Tab switches, reveals       |
| opacityFadeDurationFast  | 300  | Toasts, sheet swaps         |
| opacityFadeDurationIntro | 1200 | Hero intros, progress rings |

### Glass Helpers

`glass05(color)` 3%, `glass10` 10%, `glass15` 15%, `glass40` 40%, `glass50` 50% (scrim), `glass70` 70%

### Blur Constants

- `backdropBlurSigma`: 10 (behind modals)
- `lyricsBlurSigma`: 3 (past text de-emphasis)
- `lockedTextBlurSigma`: 6 (locked content)

### Sheet Spacing

- `sheetHeadingToSubheadingSpacing`: 4
- `sheetSubheadingToContentSpacing`: 16

### Content Padding

- `contentPaddingInsets`: 24 all sides
- `contentPaddingMediumInsets`: 12 all sides

### Dialog Padding

- `dialogOuterHorizontalInset`: 24 (screen edge to card)
- `dialogContentInsets`: 24 all sides
- `dialogStackedButtonGap`: 12
- `dialogBarrierColor`: glass50(black)

---

## Typography (RLTypography)

File: `lib/constants/RLTypography.dart`

Three font families:

- **Display**: Press Start 2P (8-bit headings)
- **UI**: JetBrains Mono (buttons, labels, menus)
- **Reading**: User-selectable (Lora / OpenDyslexic / JetBrains Mono)

### Display Styles

| Constructor   | Size | Weight   |
| ------------- | ---- | -------- |
| headingLarge  | 20   | bold     |
| headingMedium | 14   | semibold |
| pixelLabel    | 9    | semibold |
| pixelNumber   | 20   | bold     |

### UI Styles

| Constructor       | Size | Weight  |
| ----------------- | ---- | ------- |
| bodyLarge         | 16   | medium  |
| bodyMedium / text | 14   | regular |
| bodySmall         | 12   | regular |

### Reading Styles

| Constructor   | Size |
| ------------- | ---- |
| readingLarge  | 18   |
| readingMedium | 16   |

Reading font selection driven by `selectedReadingFontNotifier` (ValueNotifier). Options: serif, dyslexic, monospace. File: `lib/constants/RLReadingFont.dart`

**Rule: Never use raw `Text()`. Always use `RLTypography.*` constructors.**

---

## Layout Primitives

### Div (Container replacement)

File: `lib/design_system/RLUtility.dart`

```dart
Div.row([widgets], padding: 16, color: RLDS.surface, radius: 12, onTap: () {})
Div.column([widgets], width: 'full', margin: [0, 24])
```

- `padding`/`margin`: double (all sides), [v, h] list, [t, r, b, l] list, or EdgeInsets
- `width`/`height`: double or `'full'` for infinity
- `color`: Color object or string name ('red', 'blue', etc.)
- `radius`: double (all corners) or [tl, tr, br, bl] list
- `mainAxisAlignment`/`crossAxisAlignment`: enum or string ('center', 'spaceBetween', etc.)
- `onTap`: auto-triggers light haptic

### Spacing (SizedBox replacement)

```dart
Spacing.height(RLDS.spacing12)
Spacing.width(RLDS.spacing24)
```

### RenderIf (conditional rendering)

```dart
RenderIf.condition(
  shouldShowButton,
  PrimaryButton(),
  FallbackWidget(),  // optional, defaults to SizedBox.shrink()
)
```

---

## Components

### RLButton

File: `lib/design_system/RLButton.dart`

```dart
RLButton.primary(label: 'Next', onTap: handleNext)
RLButton.secondary(label: 'Cancel', onTap: handleCancel)
RLButton.tertiary(label: 'More', onTap: handleMore)
```

- Primary: filled with color, white text
- Secondary: transparent, colored text
- Tertiary: transparent, colored text, no border
- Default padding: vertical 16, horizontal 24
- Tap triggers haptic + random text-click sound

### RLCard

File: `lib/design_system/RLCard.dart`

```dart
RLCard.elevated(child: content, onTap: handleTap)
RLCard.subtle(child: content)
```

Default padding: 12. Wraps content in RLLunarBlur (frosted glass).

### RLLunarBlur (frosted glass)

File: `lib/design_system/RLLunarBlur.dart`

```dart
RLLunarBlur(
  child: content,
  borderRadius: borderRadius,
  blurSigma: 4.0,       // default
  surfaceAlpha: 0.35,    // default
)
```

Used on: cards, nav bar, sheets, buttons. Gives the "frosted pane over starfield" look.

### RLBottomSheet

File: `lib/bottom_sheets/RLBottomSheet.dart`

```dart
RLBottomSheet.show(context, child: content, showGrabber: true)
RLBottomSheet.showFullHeight(context, child: content)  // 90% screen
```

- Grabber: 40px wide, 4px tall pill
- Backdrop blur: sigma 10
- Background: RLDS.surface

### RLFeedbackSnackbar

File: `lib/design_system/RLFeedbackSnackbar.dart`

```dart
FeedbackSnackBar.showCorrectAnswer(context, explanation: 'text')
FeedbackSnackBar.showWrongAnswer(context, hint: 'text')
```

Slides up from bottom, 250ms animation. Uses LunarBlur. Dismissable by drag.

---

## Night Shift

Files: `lib/constants/RLNightShift.dart`, `lib/design_system/RLNightShift.dart`

5 warmth levels (0=off, 4=warmest). Applied via ColorFiltered RGB matrix at MaterialApp root.

| Level | Temp        | Brightness     |
| ----- | ----------- | -------------- |
| 0     | 6500K (off) | device default |
| 1     | 5500K       | 0.55           |
| 2     | 4500K       | 0.40           |
| 3     | 3700K       | 0.25           |
| 4     | 3400K       | 0.15           |

Schedule: daily window (default 19:00 to 06:00), auto-sets level 3 when inside window.

State: `nightShiftLevelNotifier`, `nightShiftScheduleEnabledNotifier`, `nightShiftScheduleFromMinutesNotifier`, `nightShiftScheduleToMinutesNotifier`

---

## Navigation

File: `lib/MainNavigation.dart`

3 bottom tabs: Home (0), Search (1), Bookshelf (2). All tabs stay mounted (AnimatedOpacity fade, not rebuild). External tab switching via `activeTabIndexNotifier`.

- Icon size: iconXLarge (32)
- Selected: primary, Unselected: textSecondary
- Bookshelf badge: red dot driven by `bookshelfHasUnseenPurchaseNotifier`
- Starfield background extends under nav bar (`extendBody: true`)
- Nav bar uses LunarBlur frosted over live stars

---

## Course Colors

File: `lib/constants/RLCoursePalette.dart`

12 palette colors stored as uppercase hex in Firestore. Lookup: `RLCoursePalette.byHex`. Fallback: #7D5465.

Book cover assets: `assets/books/{HEX}.png` (one per palette color + FALLBACK.png).

---

## Key File Paths

| What                   | Path                                        |
| ---------------------- | ------------------------------------------- |
| Design tokens          | `lib/constants/RLDesignSystem.dart`         |
| Typography             | `lib/constants/RLTypography.dart`           |
| Reading fonts          | `lib/constants/RLReadingFont.dart`          |
| Night shift config     | `lib/constants/RLNightShift.dart`           |
| Course colors          | `lib/constants/RLCoursePalette.dart`        |
| Div, Spacing, RenderIf | `lib/design_system/RLUtility.dart`          |
| Night shift widget     | `lib/design_system/RLNightShift.dart`       |
| LunarBlur              | `lib/design_system/RLLunarBlur.dart`        |
| Cards                  | `lib/design_system/RLCard.dart`             |
| Buttons                | `lib/design_system/RLButton.dart`           |
| Snackbar               | `lib/design_system/RLFeedbackSnackbar.dart` |
| Bottom sheets          | `lib/bottom_sheets/RLBottomSheet.dart`      |
| Main navigation        | `lib/MainNavigation.dart`                   |
| Haptics                | `lib/services/feedback/HapticsService.dart` |
| Sounds                 | `lib/services/feedback/SoundService.dart`   |
