import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:indexed_list_view/indexed_list_view.dart';
import 'package:music/common/theme.dart';
import 'package:music/core/manager/song_manager.dart';
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
          ).padding(vertical: 5).gestures(
            onTap: () {
              SongManager.changeSong(model);
              Get.back();
            },
          );
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
  final memImage = Image.memory(model.coverU8,
      fit: BoxFit.cover, errorBuilder: (c, e, s) => noImage);
  if (model.coverPath.isNotEmpty) {
    return Image.file(coverFile, fit: BoxFit.cover, errorBuilder: (c, e, s) {
      return memImage;
    });
  } else if (model.coverU8.isNotEmpty) {
    return memImage;
  }
  return noImage;
}
