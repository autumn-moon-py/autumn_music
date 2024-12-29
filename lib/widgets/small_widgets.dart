import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:music/common/theme.dart';
import 'package:music/widgets/extension_widget.dart';

Widget sb([double? width, double? height]) =>
    SizedBox(width: width?.w, height: height?.h);

Widget w(double? width) {
  return sb(width);
}

Widget h(double? height) {
  return sb(0, height);
}

Widget loadC([double? size]) {
  return CircularProgressIndicator(color: AppTheme.lightBlue).size(size);
}
