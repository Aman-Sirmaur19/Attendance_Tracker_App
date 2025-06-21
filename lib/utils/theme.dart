import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
  brightness: Brightness.light,
  fontFamily: 'Fredoka',
  appBarTheme: const AppBarTheme(
    centerTitle: true,
    backgroundColor: Color(0xFFF5F5F3),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(foregroundColor: Colors.blue),
  ),
  timePickerTheme: TimePickerThemeData(
    backgroundColor: Colors.white,
    hourMinuteTextColor: Colors.blue,
    dialHandColor: Colors.blue,
    dialBackgroundColor: Colors.blue.shade50,
    entryModeIconColor: Colors.blue,
  ),
  datePickerTheme: DatePickerThemeData(
    backgroundColor: Colors.white,
    headerBackgroundColor: Colors.blue,
    headerForegroundColor: Colors.white,
    todayBorder: const BorderSide(color: Colors.blue),
    todayForegroundColor: MaterialStateColor.resolveWith((states) =>
        states.contains(MaterialState.selected) ? Colors.white : Colors.black),
    todayBackgroundColor: MaterialStateColor.resolveWith((states) =>
        states.contains(MaterialState.selected)
            ? Colors.blue
            : Colors.transparent),
    dayForegroundColor: MaterialStateColor.resolveWith((states) =>
        states.contains(MaterialState.selected) ? Colors.white : Colors.black),
    dayBackgroundColor: MaterialStateColor.resolveWith((states) =>
        states.contains(MaterialState.selected)
            ? Colors.blue
            : Colors.transparent),
    yearForegroundColor: MaterialStateColor.resolveWith((states) =>
        states.contains(MaterialState.selected) ? Colors.white : Colors.black),
    yearBackgroundColor: MaterialStateColor.resolveWith((states) =>
        states.contains(MaterialState.selected)
            ? Colors.blue
            : Colors.transparent),
  ),
  colorScheme: const ColorScheme.light(
    background: Color(0xFFF5F5F3),
    primary: Colors.white,
    secondary: Colors.black,
    tertiary: Colors.grey,
    primaryContainer: Color(0xFFE5E5E4),
    secondaryContainer: Colors.black54,
  ),
  textSelectionTheme: TextSelectionThemeData(
    cursorColor: Colors.blue,
    selectionHandleColor: Colors.blue,
    selectionColor: Colors.blue.withOpacity(0.4),
  ),
  iconButtonTheme: IconButtonThemeData(
      style: ButtonStyle(
          foregroundColor: MaterialStateProperty.all(Colors.black))),
  useMaterial3: true,
);

ThemeData darkMode = ThemeData(
  brightness: Brightness.dark,
  fontFamily: 'Fredoka',
  appBarTheme: const AppBarTheme(
    centerTitle: true,
    backgroundColor: Colors.black,
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(foregroundColor: Colors.blue),
  ),
  timePickerTheme: TimePickerThemeData(
    backgroundColor: Colors.grey[900],
    hourMinuteTextColor: Colors.blue,
    dialHandColor: Colors.blue,
    dialBackgroundColor: Colors.black12,
    entryModeIconColor: Colors.blue,
  ),
  datePickerTheme: DatePickerThemeData(
    backgroundColor: Colors.grey[900],
    headerBackgroundColor: Colors.blue,
    headerForegroundColor: Colors.white,
    todayBorder: const BorderSide(color: Colors.blue),
    todayForegroundColor: MaterialStateColor.resolveWith((states) =>
        states.contains(MaterialState.selected)
            ? Colors.white
            : Colors.grey.shade300),
    todayBackgroundColor: MaterialStateColor.resolveWith((states) =>
        states.contains(MaterialState.selected)
            ? Colors.blue
            : Colors.transparent),
    dayForegroundColor: MaterialStateColor.resolveWith((states) =>
        states.contains(MaterialState.selected)
            ? Colors.white
            : Colors.grey.shade300),
    dayBackgroundColor: MaterialStateColor.resolveWith((states) =>
        states.contains(MaterialState.selected)
            ? Colors.blue
            : Colors.transparent),
    yearForegroundColor: MaterialStateColor.resolveWith((states) =>
        states.contains(MaterialState.selected)
            ? Colors.white
            : Colors.grey.shade300),
    yearBackgroundColor: MaterialStateColor.resolveWith((states) =>
        states.contains(MaterialState.selected)
            ? Colors.blue
            : Colors.transparent),
  ),
  colorScheme: ColorScheme.dark(
    background: Colors.black,
    primary: Colors.grey.shade900,
    secondary: Colors.white,
    tertiary: Colors.grey.shade600,
    primaryContainer: const Color(0xFF1C1C1F),
    secondaryContainer: const Color(0xFF636366),
  ),
  textSelectionTheme: TextSelectionThemeData(
    cursorColor: Colors.blue,
    selectionHandleColor: Colors.blue,
    selectionColor: Colors.blue.withOpacity(0.4),
  ),
  iconButtonTheme: IconButtonThemeData(
      style: ButtonStyle(
          foregroundColor: MaterialStateProperty.all(Colors.white))),
  useMaterial3: true,
);
