import 'dart:io';

import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:indexed_list_view/indexed_list_view.dart';
import 'package:music/common/theme.dart';
import 'package:music/core/manager/song_manager.dart';
import 'package:music/core/models/enums.dart';
import 'package:music/core/models/song_model.dart';
import 'package:music/widgets/extension_widget.dart';
import 'package:music/widgets/small_widgets.dart';

class SimplePlayList extends StatefulWidget {
  const SimplePlayList({super.key});

  @override
  State<SimplePlayList> createState() => _SimplePlayListState();
}

class _SimplePlayListState extends State<SimplePlayList> {
  final IndexedScrollController _scrollController = IndexedScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToCurrentIndex();
    });

    SongManager.currentIndex.listen((p0) {
      _scrollToCurrentIndex();
    });
  }

  void _scrollToCurrentIndex() {
    _scrollController.jumpToIndex(SongManager.currentIndex.value);
  }

  @override
  Widget build(BuildContext context) {
    final list = SongManager.playlist;

    return IndexedListView.separated(
      controller: _scrollController,
      minItemCount: 0,
      maxItemCount: list.length,
      physics: const BouncingScrollPhysics(),
      itemBuilder: (context, index) {
        final model = list[index];
        return Obx(() {
          return AppTheme.nT(
            "${index + 1}. ${model.name}",
            SongManager.currentIndex.value == index
                ? AppTheme.darkBlue
                : Colors.black,
            20,
          ).padding(vertical: 5).gestures(onTap: () {
            SongManager.changeSong(model);
            Get.back();
          });
        });
      },
      separatorBuilder: (context, index) =>
          Container(height: 1, color: Colors.black12),
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 25.h),
    ).height(1.sw);
  }
}

Widget getCoverImage(SongModel model, {bool bg = false, bool bigIcon = false}) {
  final coverFile = File(model.coverPath);

  final noImage = Stack(children: [
    Container(color: AppTheme.lightBlue),
    bg
        ? sb()
        : AppTheme.nI(Icons.music_note, AppTheme.darkBlue, bigIcon ? 100 : 25)
            .center()
  ]);

  if (model.coverPath.isNotEmpty) {
    return Image.file(coverFile, fit: BoxFit.cover, errorBuilder: (c, e, s) {
      return noImage;
    });
  }
  return noImage;
}

class SongProgressBar extends StatelessWidget {
  final SongModel model;
  const SongProgressBar({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return ProgressBar(
        progress: model.position.value,
        total: model.duration.value,
        onSeek: (duration) {
          model.player?.seek(duration);
        },
        thumbRadius: 5,
        baseBarColor: Colors.white30,
        progressBarColor: Colors.white60,
        thumbColor: Colors.white,
        timeLabelTextStyle: TextStyle(color: Colors.white),
        timeLabelPadding: 5,
      );
    });
  }
}

class SongActionButtonGroup extends StatelessWidget {
  final SongModel model;
  const SongActionButtonGroup({super.key, required this.model});

  Widget playModeB() {
    final playModeIconMap = {
      PlayMode.loop: Icons.loop,
      PlayMode.shuffle: Icons.shuffle,
      PlayMode.single: Icons.repeat_one,
    };
    return Obx(() {
      return IconButton(
          onPressed: () {
            SongManager.changePlayMode();
          },
          icon: AppTheme.nI(
              playModeIconMap[SongManager.playMode.value]!, Colors.white, 30));
    });
  }

  Widget previousB() {
    return IconButton(
        onPressed: () {
          SongManager.previous();
        },
        icon: AppTheme.nI(Icons.skip_previous, Colors.white, 40));
  }

  Widget nextB() {
    return IconButton(
        onPressed: () {
          SongManager.next();
        },
        icon: AppTheme.nI(Icons.skip_next, Colors.white, 40));
  }

  Widget playAndPauseB() {
    return Obx(() {
      return Stack(alignment: Alignment.center, children: [
        IconButton(
            onPressed: () {
              model.playOrPause();
            },
            icon: AppTheme.nI(
                !model.isPlaying.value ? Icons.play_circle : Icons.pause_circle,
                Colors.white,
                70)),
        loadC(55.sp).hide(show: model.isLoading.value)
      ]);
    });
  }

  Widget playListB() {
    return IconButton(
        onPressed: () {
          Get.bottomSheet(SimplePlayList()
              .color(Colors.white)
              .clipRRect(topLeft: 10, topRight: 10));
        },
        icon: AppTheme.nI(Icons.playlist_play, Colors.white, 30));
  }

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
      playModeB(),
      previousB(),
      playAndPauseB(),
      nextB(),
      playListB(),
    ]);
  }
}
