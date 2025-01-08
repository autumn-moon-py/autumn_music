import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mini_music_visualizer/mini_music_visualizer.dart';
import 'package:music/common/theme.dart';
import 'package:music/core/manager/song_manager.dart';
import 'package:music/core/models/song_model.dart';
import 'package:music/pages/song_detail/page.dart';
import 'package:music/pages/song_detail/widget.dart';
import 'package:music/widgets/extension_widget.dart';
import 'package:music/widgets/small_widgets.dart';
import 'package:visibility_detector/visibility_detector.dart';

Widget songCard(SongModel model) {
  return VisibilityDetector(
    key: ValueKey("${model.name} ${model.artist}"),
    onVisibilityChanged: (info) {
      if (info.visibleFraction == 1.0) {
        model.isShow(true);
      } else if (info.visibleFraction == 0.0) {
        model.isShow(false);
      } else {
        model.isShow(false);
      }
    },
    child: Row(children: [
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
      Obx(() {
        final cModel = SongManager.nowSongModel.value;
        final isPlay = cModel == model && model.isPlaying.value;
        return isPlay
            ? MiniMusicVisualizer(
                animate: true,
                color: AppTheme.darkBlue,
                width: 5,
                height: 20,
              ).padding(right: 10.w)
            : IconButton(
                onPressed: () {},
                icon: AppTheme.nI(Icons.more_vert, Colors.grey, 25));
      })
    ]).color(Colors.transparent).gestures(onTap: () {
      Get.to(SongDetilsPage(model: model));
    }, onDoubleTap: () {
      SongManager.changeSong(model);
    }).padding(bottom: 10.h),
  );
}
