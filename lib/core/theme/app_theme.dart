import 'package:flutter/material.dart';

import 'dark_theme.dart';
import 'light_theme.dart';

ThemeData appTheme(Brightness brightness) {
  switch (brightness) {
    case Brightness.light:
      return LightTheme.themeData;
    case Brightness.dark:
      return DarkTheme.themeData;
  }
}
