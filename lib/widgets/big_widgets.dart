import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:music/common/theme.dart';
import 'package:music/core/manager/song_manager.dart';
import 'package:music/core/models/enums.dart';
import 'package:music/core/models/song_model.dart';
import 'package:music/pages/song_detail/widget.dart';
import 'package:music/widgets/extension_widget.dart';
import 'package:music/widgets/small_widgets.dart';

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

class SwipeCallbackWidget extends StatefulWidget {
  final Function onSwipeLeft;
  final Function onSwipeRight;
  final Widget child;

  const SwipeCallbackWidget({
    super.key,
    required this.onSwipeLeft,
    required this.onSwipeRight,
    required this.child,
  });

  @override
  SwipeCallbackWidgetState createState() => SwipeCallbackWidgetState();
}

class SwipeCallbackWidgetState extends State<SwipeCallbackWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double _dragDistance = 0.0;
  static const double _swipeThreshold = 100.0;
  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 200))
          ..addListener(() {
            setState(() {
              _dragDistance = _controller.value;
            });
          });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    setState(() {
      _dragDistance += details.primaryDelta ?? 0;
    });
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    if (_dragDistance.abs() > _swipeThreshold) {
      if (_dragDistance > 0) {
        widget.onSwipeRight();
      } else {
        widget.onSwipeLeft();
      }
    }
    _controller.reverse(from: _dragDistance);
    _dragDistance = 0.0;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onHorizontalDragUpdate: _onHorizontalDragUpdate,
        onHorizontalDragEnd: _onHorizontalDragEnd,
        child: Transform.translate(
            offset: Offset(_dragDistance, 0), child: widget.child));
  }
}

class SearchWidget<T> extends StatefulWidget {
  final List<T> items; // 数据源列表
  final Widget Function(T item) itemBuilder; // 列表项构建器
  final bool Function(T item, String query) searchMatcher; // 搜索匹配算法
  final String hintText; // 搜索框提示文字

  const SearchWidget({
    super.key,
    required this.items,
    required this.itemBuilder,
    required this.searchMatcher,
    this.hintText = '搜索',
  });

  @override
  State<SearchWidget<T>> createState() => _SearchWidgetState<T>();
}

class _SearchWidgetState<T> extends State<SearchWidget<T>> {
  final TextEditingController _searchController = TextEditingController();
  final RxList<T> _searchResults = <T>[].obs;

  @override
  Widget build(BuildContext context) {
    return _buildSearchBar();
  }

  Widget _buildSearchBar() {
    return Container(
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: TextField(
            controller: _searchController,
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              hintText: widget.hintText,
              border: InputBorder.none,
            ),
            onChanged: _updateSearchResults,
            onTap: () {
              if (Get.currentRoute == "/") {
                Get.to(() => Scaffold(
                    appBar: AppBar(
                        title: _buildSearchBar(),
                        centerTitle: true,
                        backgroundColor: AppTheme.darkBlue,
                        actions: [
                          w(5.w),
                          IconButton(
                              icon: AppTheme.nI(Icons.clear, Colors.white, 25),
                              onPressed: () {
                                _searchController.clear();
                                _updateSearchResults('');
                              }),
                          w(10.w)
                        ],
                        leading: BackButton(color: Colors.white)),
                    body: SearchPage(
                      searchResults: _searchResults,
                      itemBuilder: widget.itemBuilder,
                    )));
              }
            }));
  }

  void _updateSearchResults(String query) {
    if (query.isEmpty) {
      _searchResults.clear();
      return;
    }
    _searchResults.value = widget.items
        .where((item) => widget.searchMatcher(item, query))
        .toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

class SearchPage<T> extends StatefulWidget {
  final RxList<T> searchResults;
  final Widget Function(T item) itemBuilder;
  const SearchPage(
      {super.key, required this.searchResults, required this.itemBuilder});

  @override
  State<SearchPage<T>> createState() => _SearchPageState<T>();
}

class _SearchPageState<T> extends State<SearchPage<T>> {
  @override
  Widget build(BuildContext context) {
    final list = widget.searchResults;
    return Scaffold(
        body: Stack(children: [
      Obx(() {
        return list.isEmpty
            ? AppTheme.bk("无搜索", 25).center()
            : ListView.builder(
                itemCount: list.length,
                padding: EdgeInsets.only(
                    left: 10.w, top: 10.h, right: 5.w, bottom: 20.h),
                itemBuilder: (context, index) {
                  return widget.itemBuilder(list[index]);
                });
      })
    ]));
  }
}
