import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

TextTheme createTextTheme(
  BuildContext context,
  String bodyFontString,
  String displayFontString,
) {
  TextTheme baseTextTheme = Theme.of(context).textTheme;
  TextTheme bodyTextTheme = GoogleFonts.getTextTheme(
    bodyFontString,
    baseTextTheme,
  );
  TextTheme displayTextTheme = GoogleFonts.getTextTheme(
    displayFontString,
    baseTextTheme,
  );
  // TextTheme textTheme = displayTextTheme.copyWith(
  //   // add all but copy with font family Noto Sans KR
  //   displayLarge: baseTextTheme.displayLarge?.copyWith(
  //     fontFamily: 'Noto Sans KR',
  //   ),
  //   displayMedium: baseTextTheme.displayMedium?.copyWith(
  //     fontFamily: 'Noto Sans KR',
  //   ),
  //   displaySmall: baseTextTheme.displaySmall?.copyWith(
  //     fontFamily: 'Noto Sans KR',
  //   ),
  //   headlineLarge: baseTextTheme.headlineLarge?.copyWith(
  //     fontFamily: 'Noto Sans KR',
  //   ),
  //   headlineMedium: baseTextTheme.headlineMedium?.copyWith(
  //     fontFamily: 'Noto Sans KR',
  //   ),
  //   headlineSmall: baseTextTheme.headlineSmall?.copyWith(
  //     fontFamily: 'Noto Sans KR',
  //   ),
  //   bodyMedium: bodyTextTheme.bodyMedium?.copyWith(fontFamily: 'Noto Sans KR'),
  //   bodySmall: bodyTextTheme.bodySmall?.copyWith(fontFamily: 'Noto Sans KR'),
  //   labelLarge: bodyTextTheme.labelLarge?.copyWith(fontFamily: 'Noto Sans KR'),
  //   labelMedium: bodyTextTheme.labelMedium?.copyWith(
  //     fontFamily: 'Noto Sans KR',
  //   ),
  //   labelSmall: bodyTextTheme.labelSmall?.copyWith(fontFamily: 'Noto Sans KR'),
  // );

  TextTheme textTheme = baseTextTheme;

  String fontFamily = 'NotoSansKR';

  // create new text theme
  // all must have Noto Sans KR as font family
  textTheme = textTheme.copyWith(
    displayLarge: displayTextTheme.displayLarge?.copyWith(
      fontFamily: fontFamily,
    ),
    displayMedium: displayTextTheme.displayMedium?.copyWith(
      fontFamily: fontFamily,
    ),
    displaySmall: displayTextTheme.displaySmall?.copyWith(
      fontFamily: fontFamily,
    ),
    headlineLarge: textTheme.headlineLarge?.copyWith(fontFamily: fontFamily),
    headlineMedium: textTheme.headlineMedium?.copyWith(fontFamily: fontFamily),
    headlineSmall: textTheme.headlineSmall?.copyWith(fontFamily: fontFamily),
    bodyLarge: bodyTextTheme.bodyLarge?.copyWith(fontFamily: fontFamily),
    bodyMedium: bodyTextTheme.bodyMedium?.copyWith(fontFamily: fontFamily),
    bodySmall: bodyTextTheme.bodySmall?.copyWith(fontFamily: fontFamily),
    labelLarge: textTheme.labelLarge?.copyWith(fontFamily: fontFamily),
    labelMedium: textTheme.labelMedium?.copyWith(fontFamily: fontFamily),
    labelSmall: textTheme.labelSmall?.copyWith(fontFamily: fontFamily),
  );

  return textTheme;
}
