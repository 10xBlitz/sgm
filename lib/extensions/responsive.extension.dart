import 'package:flutter/material.dart';

/// Extension on [MediaQueryData] to provide easy responsive design helpers.
///
/// This extension adds helper methods to determine the device type
/// (phone, tablet, desktop, wide) based on screen width breakpoints.
extension ResponsiveExtension on MediaQueryData {
  /// Breakpoint for small devices (phones).
  static const double phoneBreakpoint = 600;

  /// Breakpoint for medium devices (tablets).
  static const double tabletBreakpoint = 900;

  /// Breakpoint for large devices (desktops).
  static const double desktopBreakpoint = 1200;

  /// Returns true if the screen width is less than 600 logical pixels.
  ///
  /// This is typically used to identify mobile phones in portrait mode.
  bool get isPhone => size.width < phoneBreakpoint;

  /// Returns true if the screen width is between 600 and 899 logical pixels.
  ///
  /// This is typically used to identify tablets in portrait mode or large phones
  /// in landscape mode.
  bool get isTablet =>
      size.width >= phoneBreakpoint && size.width < tabletBreakpoint;

  /// Returns true if the screen width is between 900 and 1199 logical pixels.
  ///
  /// This is typically used to identify large tablets in landscape mode or small
  /// desktop windows.
  bool get isDesktop =>
      size.width >= tabletBreakpoint && size.width < desktopBreakpoint;

  /// Returns true if the screen width is 1200 logical pixels or wider.
  ///
  /// This is typically used to identify wide desktop screens or TVs.
  bool get isWide => size.width >= desktopBreakpoint;

  /// Returns true if the screen width is less than 900 logical pixels.
  ///
  /// This combines phone and tablet categories for layouts that should be similar
  /// on smaller screens.
  bool get isTabletOrNarrower => size.width < tabletBreakpoint;

  /// Returns true if the screen width is less than 1200 logical pixels.
  ///
  /// This combines phone, tablet, and desktop categories, excluding only the
  /// widest screens.
  bool get isDesktopOrNarrower => size.width < desktopBreakpoint;

  /// Returns true if the screen width is 600 logical pixels or wider.
  ///
  /// This combines tablet, desktop, and wide categories for layouts that should
  /// be similar on larger screens.
  bool get isTabletOrWider => size.width >= phoneBreakpoint;

  /// Returns true if the screen width is 900 logical pixels or wider.
  ///
  /// This combines desktop and wide categories for layouts that require
  /// significant horizontal space.
  bool get isDesktopOrWider => size.width >= tabletBreakpoint;
}