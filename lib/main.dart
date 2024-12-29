import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:music/pages/home/page.dart';

import 'common/global.dart';

Future<void> main() async {
  await Global.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
        designSize: Size(344, 768),
        child: GetMaterialApp(
          title: '秋月音乐',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(useMaterial3: true),
          home: const MyHomePage(),
        ));
  }
}
