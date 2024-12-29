import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:keframe/keframe.dart';
import 'package:music/common/theme.dart';
import 'package:music/core/models/song_model.dart';
import 'package:music/widgets/extension_widget.dart';

import 'widget.dart';

class SongListPage extends StatelessWidget {
  final List<SongModel> list;
  const SongListPage({super.key, required this.list});

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      list.isEmpty
          ? AppTheme.bk("暂无歌曲", 20).center()
          : SizeCacheWidget(
              child: ListView.builder(
                  padding: EdgeInsets.only(top: 10.h, bottom: 200.h),
                  itemCount: list.length,
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
