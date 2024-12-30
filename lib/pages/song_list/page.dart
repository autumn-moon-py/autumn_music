import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:indexed_list_view/indexed_list_view.dart';
import 'package:keframe/keframe.dart';
import 'package:music/common/theme.dart';
import 'package:music/core/models/song_model.dart';
import 'package:music/widgets/extension_widget.dart';

import 'widget.dart';

class SongListPage extends StatelessWidget {
  final List<SongModel> list;
  final IndexedScrollController controller;
  const SongListPage({super.key, required this.list, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      list.isEmpty
          ? AppTheme.bk("暂无歌曲", 20).center()
          : SizeCacheWidget(
              child: IndexedListView.builder(
                  minItemCount: 0,
                  maxItemCount: list.length - 1,
                  controller: controller,
                  padding: EdgeInsets.only(top: 0, bottom: 20.h),
                  itemBuilder: (c, index) {
                    return FrameSeparateWidget(
                      index: index,
                      child:
                          songCard(list[index]).padding(left: 15.w, right: 5.w),
                    );
                  }).height(1.sh))
    ]);
  }
}
