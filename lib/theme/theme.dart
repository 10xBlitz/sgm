import "package:flutter/material.dart";

class MaterialTheme {
  final TextTheme textTheme;

  const MaterialTheme(this.textTheme);

  static ColorScheme lightScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      // primary: Color(0xff715c24),
      primary: Color(0xffceb271),
      surfaceTint: Color(0xff715c24),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xffceb271),
      onPrimaryContainer: Color(0xff58440d),
      secondary: Color(0xff62602d),
      onSecondary: Color(0xffffffff),
      // secondaryContainer: Color(0xfffaf6b4),
      secondaryContainer: Color.fromARGB(255, 236, 225, 198),
      // onSecondaryContainer: Color.fromARGB(255, 172, 135, 42),
      onSecondaryContainer: Color.fromARGB(255, 188, 161, 110),
      tertiary: Color(0xff4e586c),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff667085),
      onTertiaryContainer: Color(0xfff2f4ff),
      error: Color(0xffba1a1a),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffffdad6),
      onErrorContainer: Color(0xff93000a),
      surface: Color(0xfffff8f1),
      onSurface: Color(0xff1e1b17),
      onSurfaceVariant: Color(0xff4c463a),
      outline: Color(0xff7e7668),
      outlineVariant: Color(0xffcfc5b5),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff33302b),
      inversePrimary: Color(0xffe0c381),
      primaryFixed: Color(0xfffedf9a),
      onPrimaryFixed: Color(0xff251a00),
      primaryFixedDim: Color(0xffe0c381),
      onPrimaryFixedVariant: Color(0xff58440d),
      secondaryFixed: Color(0xffe9e5a5),
      onSecondaryFixed: Color(0xff1e1d00),
      secondaryFixedDim: Color(0xffcdc98b),
      onSecondaryFixedVariant: Color(0xff4a4918),
      tertiaryFixed: Color(0xffd9e3fb),
      onTertiaryFixed: Color(0xff111c2d),
      tertiaryFixedDim: Color(0xffbdc7de),
      onTertiaryFixedVariant: Color(0xff3d475a),
      surfaceDim: Color(0xffe0d9d1),
      surfaceBright: Color(0xfffff8f1),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfffaf2ea),
      surfaceContainer: Color(0xfff4ede5),
      surfaceContainerHigh: Color(0xffeee7df),
      surfaceContainerHighest: Color(0xffe8e1da),
    );
  }

  ThemeData light() {
    return theme(lightScheme());
  }

  static ColorScheme lightMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff453400),
      surfaceTint: Color(0xff715c24),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff816a31),
      onPrimaryContainer: Color(0xffffffff),
      secondary: Color(0xff393807),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff716f3a),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xff2c3649),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff636d82),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xff740006),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffcf2c27),
      onErrorContainer: Color(0xffffffff),
      surface: Color(0xfffff8f1),
      onSurface: Color(0xff13110d),
      onSurfaceVariant: Color(0xff3b362a),
      outline: Color(0xff585245),
      outlineVariant: Color(0xff746c5e),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff33302b),
      inversePrimary: Color(0xffe0c381),
      primaryFixed: Color(0xff816a31),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff67521b),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xff716f3a),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff595724),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff636d82),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff4b5569),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffccc5be),
      surfaceBright: Color(0xfffff8f1),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfffaf2ea),
      surfaceContainer: Color(0xffeee7df),
      surfaceContainerHigh: Color(0xffe3dcd4),
      surfaceContainerHighest: Color(0xffd7d1c9),
    );
  }

  ThemeData lightMediumContrast() {
    return theme(lightMediumContrastScheme());
  }

  static ColorScheme lightHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff392a00),
      surfaceTint: Color(0xff715c24),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff5a4610),
      onPrimaryContainer: Color(0xffffffff),
      secondary: Color(0xff2f2e00),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff4d4b1a),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xff222c3e),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff3f495d),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xff600004),
      onError: Color(0xffffffff),
      errorContainer: Color(0xff98000a),
      onErrorContainer: Color(0xffffffff),
      surface: Color(0xfffff8f1),
      onSurface: Color(0xff000000),
      onSurfaceVariant: Color(0xff000000),
      outline: Color(0xff312c20),
      outlineVariant: Color(0xff4f483c),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff33302b),
      inversePrimary: Color(0xffe0c381),
      primaryFixed: Color(0xff5a4610),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff413000),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xff4d4b1a),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff363405),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff3f495d),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff293345),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffbeb8b0),
      surfaceBright: Color(0xfffff8f1),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfff7f0e8),
      surfaceContainer: Color(0xffe8e1da),
      surfaceContainerHigh: Color(0xffdad3cc),
      surfaceContainerHighest: Color(0xffccc5be),
    );
  }

  ThemeData lightHighContrast() {
    return theme(lightHighContrastScheme());
  }

  static ColorScheme darkScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffebcd8a),
      surfaceTint: Color(0xffe0c381),
      onPrimary: Color(0xff3e2e00),
      primaryContainer: Color(0xffceb271),
      onPrimaryContainer: Color(0xff58440d),
      secondary: Color(0xffffffff),
      onSecondary: Color(0xff333203),
      secondaryContainer: Color(0xffe9e5a5),
      onSecondaryContainer: Color(0xff696632),
      tertiary: Color(0xffbdc7de),
      onTertiary: Color(0xff273143),
      tertiaryContainer: Color(0xff667085),
      onTertiaryContainer: Color(0xfff2f4ff),
      error: Color(0xffffb4ab),
      onError: Color(0xff690005),
      errorContainer: Color(0xff93000a),
      onErrorContainer: Color(0xffffdad6),
      surface: Color(0xff15130f),
      onSurface: Color(0xffe8e1da),
      onSurfaceVariant: Color(0xffcfc5b5),
      outline: Color(0xff989081),
      outlineVariant: Color(0xff4c463a),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffe8e1da),
      inversePrimary: Color(0xff715c24),
      primaryFixed: Color(0xfffedf9a),
      onPrimaryFixed: Color(0xff251a00),
      primaryFixedDim: Color(0xffe0c381),
      onPrimaryFixedVariant: Color(0xff58440d),
      secondaryFixed: Color(0xffe9e5a5),
      onSecondaryFixed: Color(0xff1e1d00),
      secondaryFixedDim: Color(0xffcdc98b),
      onSecondaryFixedVariant: Color(0xff4a4918),
      tertiaryFixed: Color(0xffd9e3fb),
      onTertiaryFixed: Color(0xff111c2d),
      tertiaryFixedDim: Color(0xffbdc7de),
      onTertiaryFixedVariant: Color(0xff3d475a),
      surfaceDim: Color(0xff15130f),
      surfaceBright: Color(0xff3c3933),
      surfaceContainerLowest: Color(0xff100e0a),
      surfaceContainerLow: Color(0xff1e1b17),
      surfaceContainer: Color(0xff221f1a),
      surfaceContainerHigh: Color(0xff2c2a25),
      surfaceContainerHighest: Color(0xff37342f),
    );
  }

  ThemeData dark() {
    return theme(darkScheme());
  }

  static ColorScheme darkMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xfff7d994),
      surfaceTint: Color(0xffe0c381),
      onPrimary: Color(0xff312400),
      primaryContainer: Color(0xffceb271),
      onPrimaryContainer: Color(0xff352700),
      secondary: Color(0xffffffff),
      onSecondary: Color(0xff333203),
      secondaryContainer: Color(0xffe9e5a5),
      onSecondaryContainer: Color(0xff4b4a19),
      tertiary: Color(0xffd2dcf5),
      onTertiary: Color(0xff1c2638),
      tertiaryContainer: Color(0xff8791a7),
      onTertiaryContainer: Color(0xff000000),
      error: Color(0xffffd2cc),
      onError: Color(0xff540003),
      errorContainer: Color(0xffff5449),
      onErrorContainer: Color(0xff000000),
      surface: Color(0xff15130f),
      onSurface: Color(0xffffffff),
      onSurfaceVariant: Color(0xffe5dbca),
      outline: Color(0xffbab1a1),
      outlineVariant: Color(0xff988f80),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffe8e1da),
      inversePrimary: Color(0xff59450e),
      primaryFixed: Color(0xfffedf9a),
      onPrimaryFixed: Color(0xff181000),
      primaryFixedDim: Color(0xffe0c381),
      onPrimaryFixedVariant: Color(0xff453400),
      secondaryFixed: Color(0xffe9e5a5),
      onSecondaryFixed: Color(0xff131200),
      secondaryFixedDim: Color(0xffcdc98b),
      onSecondaryFixedVariant: Color(0xff393807),
      tertiaryFixed: Color(0xffd9e3fb),
      onTertiaryFixed: Color(0xff071122),
      tertiaryFixedDim: Color(0xffbdc7de),
      onTertiaryFixedVariant: Color(0xff2c3649),
      surfaceDim: Color(0xff15130f),
      surfaceBright: Color(0xff47443e),
      surfaceContainerLowest: Color(0xff090704),
      surfaceContainerLow: Color(0xff201d19),
      surfaceContainer: Color(0xff2a2723),
      surfaceContainerHigh: Color(0xff35322d),
      surfaceContainerHighest: Color(0xff413d38),
    );
  }

  ThemeData darkMediumContrast() {
    return theme(darkMediumContrastScheme());
  }

  static ColorScheme darkHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffffeece),
      surfaceTint: Color(0xffe0c381),
      onPrimary: Color(0xff000000),
      primaryContainer: Color(0xffdcbf7d),
      onPrimaryContainer: Color(0xff110a00),
      secondary: Color(0xffffffff),
      onSecondary: Color(0xff000000),
      secondaryContainer: Color(0xffe9e5a5),
      onSecondaryContainer: Color(0xff2d2b00),
      tertiary: Color(0xffebf0ff),
      onTertiary: Color(0xff000000),
      tertiaryContainer: Color(0xffb9c3da),
      onTertiaryContainer: Color(0xff020b1c),
      error: Color(0xffffece9),
      onError: Color(0xff000000),
      errorContainer: Color(0xffffaea4),
      onErrorContainer: Color(0xff220001),
      surface: Color(0xff15130f),
      onSurface: Color(0xffffffff),
      onSurfaceVariant: Color(0xffffffff),
      outline: Color(0xfffaefdd),
      outlineVariant: Color(0xffcbc1b1),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffe8e1da),
      inversePrimary: Color(0xff59450e),
      primaryFixed: Color(0xfffedf9a),
      onPrimaryFixed: Color(0xff000000),
      primaryFixedDim: Color(0xffe0c381),
      onPrimaryFixedVariant: Color(0xff181000),
      secondaryFixed: Color(0xffe9e5a5),
      onSecondaryFixed: Color(0xff000000),
      secondaryFixedDim: Color(0xffcdc98b),
      onSecondaryFixedVariant: Color(0xff131200),
      tertiaryFixed: Color(0xffd9e3fb),
      onTertiaryFixed: Color(0xff000000),
      tertiaryFixedDim: Color(0xffbdc7de),
      onTertiaryFixedVariant: Color(0xff071122),
      surfaceDim: Color(0xff15130f),
      surfaceBright: Color(0xff53504a),
      surfaceContainerLowest: Color(0xff000000),
      surfaceContainerLow: Color(0xff221f1a),
      surfaceContainer: Color(0xff33302b),
      surfaceContainerHigh: Color(0xff3e3b36),
      surfaceContainerHighest: Color(0xff4a4641),
    );
  }

  ThemeData darkHighContrast() {
    return theme(darkHighContrastScheme());
  }

  ThemeData theme(ColorScheme colorScheme) => ThemeData(
    useMaterial3: true,
    brightness: colorScheme.brightness,
    colorScheme: colorScheme,
    textTheme: textTheme.apply(
      bodyColor: colorScheme.onSurface,
      displayColor: colorScheme.onSurface,
    ),
    scaffoldBackgroundColor: colorScheme.surface,
    canvasColor: colorScheme.surface,
  );

  List<ExtendedColor> get extendedColors => [];
}

class ExtendedColor {
  final Color seed, value;
  final ColorFamily light;
  final ColorFamily lightHighContrast;
  final ColorFamily lightMediumContrast;
  final ColorFamily dark;
  final ColorFamily darkHighContrast;
  final ColorFamily darkMediumContrast;

  const ExtendedColor({
    required this.seed,
    required this.value,
    required this.light,
    required this.lightHighContrast,
    required this.lightMediumContrast,
    required this.dark,
    required this.darkHighContrast,
    required this.darkMediumContrast,
  });
}

class ColorFamily {
  const ColorFamily({
    required this.color,
    required this.onColor,
    required this.colorContainer,
    required this.onColorContainer,
  });

  final Color color;
  final Color onColor;
  final Color colorContainer;
  final Color onColorContainer;
}
