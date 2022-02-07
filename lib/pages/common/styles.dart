import 'package:flutter/material.dart';


abstract class AppStyle
{
  static const liteColors = AppColors(
    primaryColor: Color(0xff212121),
    primaryDarkColor: Color(0xff111111),
    linksColor: Color(0xff6a9dff),
    buttonColor: Color(0xff212121),
    secondaryColor: Color(0xff9e9e9e),
    backgroundColor: Color(0xffe8e8e8),
    cardColor: Color(0xffffffff),
    textFieldColor: Color(0xffffffff),
    textColor: Color(0xffb5b5b5),
    headerTextColor: Color(0xffffffff),
    errorColor: Color(0xffb00020),
    criticalColor: Color(0xffffb9b9),
    criticalDarkColor: Color(0xff740303),
    successColor: Color(0xffc9ffb9),
    successDarkColor: Color(0xff1e8016),
    dividerColor: Color(0xfffdfdfd),
    toastBackground: Color(0xc6111111),
    toastForeground: Color(0xfffdfdfd),
    grip: Color(0xff7f7f7f),
  );

  static const toasts = Toasts(
    borderRadius: BorderRadius.all(Radius.circular(8.0)),
    duration: Duration(milliseconds: 3200),
    animDuration: Duration(milliseconds: 250),
  );

  static const pagePadding = EdgeInsets.symmetric(horizontal: 24.0);
  static const tabStyle = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.normal,
  );
  static const inactiveTabStyle = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.normal,
  );
}

class AppColors
{
  final Color primaryColor;
  final Color primaryDarkColor;
  final Color linksColor;
  final Color buttonColor;
  final Color secondaryColor;
  final Color backgroundColor;
  final Color cardColor;
  final Color textFieldColor;
  final Color textColor;
  final Color headerTextColor;
  final Color errorColor;
  final Color criticalColor;
  final Color criticalDarkColor;
  final Color successColor;
  final Color successDarkColor;
  final Color dividerColor;
  final Color toastBackground;
  final Color toastForeground;
  final Color grip;

  const AppColors({
    required this.primaryColor,
    required this.primaryDarkColor,
    required this.linksColor,
    required this.buttonColor,
    required this.secondaryColor,
    required this.backgroundColor,
    required this.cardColor,
    required this.textFieldColor,
    required this.textColor,
    required this.headerTextColor,
    required this.errorColor,
    required this.criticalColor,
    required this.criticalDarkColor,
    required this.successColor,
    required this.successDarkColor,
    required this.dividerColor,
    required this.toastBackground,
    required this.toastForeground,
    required this.grip,
  });
}


class Toasts
{
  final BorderRadius borderRadius;
  final Duration duration;
  final Duration animDuration;

  const Toasts({
    required this.borderRadius,
    required this.duration,
    required this.animDuration,
  });
}


class Input
{
  final BorderRadius borderRadius;
  final BorderSide borderSide;
  final EdgeInsets contentPadding;
  final EdgeInsets dropdownPadding;
  final EdgeInsets collapsedContentPadding;
  final double height;
  final BoxConstraints? iconConstraints;

  /// The factor to apply to the filledColor opacity for disabled state of a
  /// TextField. The value could be in the range between 0.0 and 1.0.
  final double disabledFactor;

  const Input({
    required this.borderRadius,
    required this.borderSide,
    required this.contentPadding,
    required this.dropdownPadding,
    required this.collapsedContentPadding,
    required this.disabledFactor,
    required this.height,
    this.iconConstraints,
  })
  : assert(disabledFactor >= 0.0 && disabledFactor <= 1.0);
}
