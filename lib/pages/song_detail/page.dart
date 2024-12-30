import 'package:blur/blur.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:music/common/theme.dart';
import 'package:music/core/manager/song_manager.dart';
import 'package:music/core/models/song_model.dart';
import 'package:music/pages/song_detail/widget.dart';
import 'package:music/widgets/big_widgets.dart';
import 'package:music/widgets/extension_widget.dart';
import 'package:music/widgets/small_widgets.dart';

class SongDetilsPage extends StatefulWidget {
  const SongDetilsPage({super.key});

  @override
  State<SongDetilsPage> createState() => _SongDetilsPageState();
}

class _SongDetilsPageState extends State<SongDetilsPage> {
  Widget top(SongModel model) {
    return Row(children: [
      IconButton(
          onPressed: () {
            Get.back();
          },
          icon: AppTheme.nI(Icons.arrow_downward, Colors.white, 25)),
      Spacer(),
      IconButton(
          onPressed: () async {
            Get.bottomSheet(moreActionMenu(model)
                .color(Colors.white)
                .clipRRect(topLeft: 10, topRight: 10));
          },
          icon: AppTheme.nI(Icons.more_horiz, Colors.white, 25)),
    ]).padding(horizontal: 10.w);
  }

  Widget moreActionMenu(SongModel model) {
    return Column(children: [
      ListTile(
          title: AppTheme.bk("标记待处理", 20),
          onTap: () {
            Get.back();
            model.mark();
          }),
      ListTile(
          title: AppTheme.bk("刷新封面", 20),
          onTap: () async {
            Get.back();
            await model.refreshCover();
            setState(() {});
          }),
    ]).padding(vertical: 30.h);
  }

  Widget songPage(SongModel model) {
    return Stack(children: [
      getCoverImage(model, bg: true).height(1.sh).blurred(blur: 80),
      Container(color: Colors.black.withValues(alpha: 0.2)).gestures(
          onVerticalDragUpdate: (details) {
        if (details.delta.dy > 0) {
          Get.back();
        }
      }),
      SwipeCallbackWidget(
        onSwipeLeft: () {
          SongManager.previous();
        },
        onSwipeRight: () {
          SongManager.next();
        },
        child: Column(children: [
          h(50),
          getCoverImage(model, bigIcon: true)
              .size(0.9.sw)
              .clipRRect(all: 10)
              .decorated(boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.5), blurRadius: 20),
          ]),
          h(20),
          AppTheme.w(model.name, 30, true).padding(horizontal: 20.w),
          h(10),
          AppTheme.w(model.artist, 18).padding(horizontal: 10.w),
        ]).width(1.sw),
      ),
    ]);
  }

  Widget bottom(SongModel model) {
    return Column(children: [
      Spacer(),
      SongProgressBar(model: model).padding(horizontal: 20.w).height(20),
      h(20),
      SongActionButtonGroup(model: model).padding(horizontal: 10.w),
      h(20)
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final model = SongManager.nowSongModel.value;

      return Scaffold(
          body: Stack(children: [
        songPage(model),
        top(model),
        bottom(model),
      ])).safeArea();
    });
  }
}
