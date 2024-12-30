import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:music/common/global.dart';
import 'package:music/common/theme.dart';
import 'package:music/widgets/small_widgets.dart';

class LogViewerPage extends StatefulWidget {
  const LogViewerPage({super.key});

  @override
  State<LogViewerPage> createState() => _LogViewerPageState();
}

class _LogViewerPageState extends State<LogViewerPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            backgroundColor: AppTheme.darkBlue,
            title: AppTheme.w('日志', 20),
            centerTitle: true,
            leading: BackButton(
              color: Colors.white,
            ),
            actions: [
              IconButton(
                  icon: AppTheme.nI(Icons.refresh, Colors.white, 25),
                  onPressed: () {
                    setState(() {});
                  }),
              IconButton(
                  icon: AppTheme.nI(Icons.clear_all, Colors.white, 25),
                  onPressed: () {
                    Global.log.logList.clear();
                  }),
              w(10)
            ]),
        body: Stack(children: [
          ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 20.h),
              itemCount: Global.log.logList.length,
              itemBuilder: (context, index) {
                return AppTheme.nT2(
                    Global.log.logList[index], Colors.black, 15);
              })
        ]));
  }
}
