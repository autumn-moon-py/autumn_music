import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:indexed_list_view/indexed_list_view.dart';
import 'package:music/common/theme.dart';
import 'package:music/core/manager/song_manager.dart';
import 'package:music/pages/setting/page.dart';
import 'package:music/pages/song_detail/page.dart';
import 'package:music/pages/song_detail/widget.dart';
import 'package:music/pages/song_list/page.dart';
import 'package:music/pages/song_list/widget.dart';
import 'package:music/widgets/big_widgets.dart';
import 'package:music/widgets/extension_widget.dart';
import 'package:music/widgets/small_widgets.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final controller = IndexedScrollController();

  Widget bottom() {
    return Obx(() {
      final model = SongManager.nowSongModel.value;
      final load = model.isLoading.value;

      final coverImage = getCoverImage(model).size(40.w).clipRRect(all: 5);

      final songNameAndArtist = Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppTheme.bk(model.name, 17).width(140.w),
            AppTheme.g(model.artist, 13).width(140.w),
          ]);

      final playAndPauseB = IconButton(
          onPressed: () {
            model.playOrPause();
          },
          icon: Stack(alignment: Alignment.center, children: [
            AppTheme.nI(
                model.isPlaying.value
                    ? Icons.pause_rounded
                    : Icons.play_arrow_rounded,
                Colors.black,
                35),
            loadC(25.sp).hide(show: load)
          ]));

      final nextB = IconButton(
          onPressed: () {
            SongManager.next();
          },
          icon: AppTheme.nI(Icons.skip_next_rounded, Colors.black, 35));

      final child = Row(children: [
        coverImage,
        w(15),
        songNameAndArtist,
        Spacer(),
        playAndPauseB,
        nextB
      ]);

      return child
          .padding(left: 15.w, right: 5.w, vertical: 5.h)
          .color(Colors.white)
          .border(bottom: 1, color: Colors.grey.shade300)
          .gestures(onTap: () {
        if (model.name.isEmpty) return;
        Get.to(() => RxSongDetilsPage(), transition: Transition.downToUp);
      });
    });
  }

  AppBar buildAppbar() {
    final menuB = Builder(builder: (context) {
      return IconButton(
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
          icon: AppTheme.nI(Icons.menu, Colors.white, 25));
    });

    final settingB = IconButton(
        onPressed: () {
          Get.to(() => SettingPage(), transition: Transition.rightToLeft);
        },
        icon: AppTheme.nI(Icons.settings, Colors.white, 25));

    final searchWidget = SearchWidget(
        items: SongManager.playlist.value,
        itemBuilder: songCard,
        searchMatcher: (item, query) {
          if (item.name.contains(query)) {
            return true;
          }
          if (item.artist.contains(query)) {
            return true;
          }
          return false;
        });

    return AppBar(
        title: searchWidget,
        centerTitle: true,
        backgroundColor: AppTheme.darkBlue,
        leading: menuB,
        actions: [settingB, w(10)]);
  }

  Widget buildDrawer() {
    return Drawer(
        child: ListView(padding: EdgeInsets.zero, children: [
      DrawerHeader(
          decoration: BoxDecoration(color: AppTheme.darkBlue),
          child: AppTheme.w("菜单", 20)),
      ListTile(
          title: AppTheme.bk("待处理音乐", 17),
          onTap: () {
            Get.back();
            Get.to(() => Scaffold(
                appBar: AppBar(
                  title: AppTheme.w("歌曲列表", 20),
                  centerTitle: true,
                  backgroundColor: AppTheme.darkBlue,
                  leading: BackButton(color: Colors.white),
                ),
                body: SongListPage(
                    controller: controller,
                    list: SongManager.getPendingProcessingSongs())));
          })
    ]));
  }

  Widget buildBody() {
    return Column(children: [
      Obx(() {
        final list = SongManager.playlist.value;
        return SongListPage(list: list, controller: controller);
      }).expanded(),
      bottom()
    ]).height(1.sh);
  }

  Widget buildFloatB() {
    return Obx(() {
      final show = !SongManager.nowSongModel.value.isShow.value &&
          SongManager.playlist.isNotEmpty;
      return FloatingActionButton(
        onPressed: () {
          controller.jumpToIndex(SongManager.currentIndex.value);
        },
        child: AppTheme.nI(Icons.search, Colors.black, 25),
      ).padding(bottom: 50.h).hide(show: show);
    }).hide();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: buildAppbar(),
      drawer: buildDrawer(),
      body: buildBody(),
      floatingActionButton: buildFloatB(),
    );
  }
}
