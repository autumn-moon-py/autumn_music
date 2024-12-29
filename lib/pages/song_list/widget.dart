import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:music/common/theme.dart';
import 'package:music/core/manager/song_manager.dart';
import 'package:music/core/models/song_model.dart';
import 'package:music/pages/song_detail/widget.dart';
import 'package:music/widgets/extension_widget.dart';
import 'package:music/widgets/small_widgets.dart';

Widget songCard(SongModel model) {
  return Row(children: [
    getCoverImage(model).size(45.w).clipRRect(all: 5),
    w(15),
    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisSize: MainAxisSize.min, children: [
        sb(8, 8).color(AppTheme.darkBlue).clipOval().padding(top: 2),
        w(5),
        AppTheme.bk(model.name, 18).width(190.w),
      ]),
      AppTheme.g(model.artist, 13).width(180.w),
    ]),
    Spacer(),
    IconButton(
        onPressed: () {}, icon: AppTheme.nI(Icons.more_vert, Colors.grey, 25))
  ]).color(Colors.transparent).gestures(onTap: () {
    SongManager.changeSong(model);
  }).padding(bottom: 10.h);
}
