import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
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

import 'common/global.dart';

Future<void> main() async {
  await Global.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
        designSize: Size(344, 768),
        child: GetMaterialApp(
          title: '秋月音乐',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(useMaterial3: true),
          home: const MyHomePage(),
        ));
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  Widget bottom() {
    return Obx(() {
      final model = SongManager.nowSongModel.value;
      final load = model.isLoading.value;
      return Row(children: [
        getCoverImage(model).size(40.w).clipRRect(all: 5),
        w(15),
        Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppTheme.bk(model.name, 17).width(140.w),
              AppTheme.g(model.artist, 13).width(140.w),
            ]),
        Spacer(),
        IconButton(
            onPressed: () {
              model.playOrPause();
            },
            icon: load
                ? loadC(25.sp)
                : AppTheme.nI(
                    model.isPlaying.value
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                    Colors.black,
                    35)),
        IconButton(
            onPressed: () {
              SongManager.next();
            },
            icon: AppTheme.nI(Icons.skip_next_rounded, Colors.black, 35)),
      ])
          .gestures(onTap: () {
            Get.to(() => SongDetilsPage(), transition: Transition.downToUp);
          })
          .padding(left: 15.w, right: 5.w, vertical: 5.h)
          .color(Colors.white)
          .border(bottom: 1, color: Colors.grey.shade300);
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
          title: SearchWidget(
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
            },
          ),
          centerTitle: true,
          backgroundColor: AppTheme.darkBlue,
          leading: Builder(builder: (context) {
            return IconButton(
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
                icon: AppTheme.nI(Icons.menu, Colors.white, 25));
          }),
          actions: [
            IconButton(
                onPressed: () {
                  Get.to(() => SettingPage(),
                      transition: Transition.rightToLeft);
                },
                icon: AppTheme.nI(Icons.settings, Colors.white, 25)),
            w(10)
          ]),
      drawer: Drawer(
          child: ListView(padding: EdgeInsets.zero, children: [
        DrawerHeader(
          decoration: BoxDecoration(
            color: AppTheme.darkBlue,
          ),
          child: AppTheme.w("菜单", 20),
        ),
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
                    list: SongManager.getPendingProcessingSongs())));
          },
        )
      ])),
      body: Stack(children: [
        Container(color: Colors.white),
        Obx(() {
          final list = SongManager.playlist.value;
          return SongListPage(list: list);
        }),
        bottom().alignment(Alignment.bottomCenter),
      ]),
    );
  }
}
