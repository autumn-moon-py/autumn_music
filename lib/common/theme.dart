import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppTheme {
  static Widget nT(String text, Color color, double size, [bool bold = false]) {
    return Text(text,
        style: TextStyle(
            color: color,
            fontSize: size.sp,
            overflow: TextOverflow.ellipsis,
            fontWeight: bold ? FontWeight.bold : FontWeight.normal));
  }

  static Widget nT2(String text, Color color, double size,
      [bool bold = false]) {
    return Text(text,
        style: TextStyle(
            color: color,
            fontSize: size.sp,
            fontWeight: bold ? FontWeight.bold : FontWeight.normal));
  }

  static Widget nI(IconData icon, Color color, double size) {
    return Icon(icon, color: color, size: size.sp);
  }

  static Widget bk(String text, double size, [bool bold = false]) {
    return nT(text, Colors.black, size, bold);
  }

  static Widget g(String text, double size, [bool bold = false]) {
    return nT(text, Colors.grey, size, bold);
  }

  static Widget w(String text, double size, [bool bold = false]) {
    return nT(text, Colors.white, size, bold);
  }

  static Color lightBlue = const Color.fromARGB(255, 101, 168, 255);
  static Color darkBlue = const Color.fromARGB(255, 0, 100, 255);
}
