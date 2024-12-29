import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:music/common/global.dart';
import 'package:music/common/theme.dart';
import 'package:music/core/manager/song_manager.dart';
import 'package:music/core/service/r2.dart';
import 'package:music/utils/cache_tools.dart';
import 'package:music/utils/noraml_tools.dart';
import 'package:music/widgets/extension_widget.dart';
import 'package:music/widgets/small_widgets.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  var songCache = 0.obs;
  var coverCache = 0.obs;

  var songCacheCleanging = false.obs;
  var coverCacheCleanging = false.obs;

  List<File> songCacheList = [];
  List<File> coverCacheList = [];

  @override
  void initState() {
    init();
    super.initState();
  }

  Future<void> init() async {
    songCacheList = await CacheTool.getMusicAllFiles();
    songCache.value = CacheTool.getAllFilesSize(songCacheList);
    coverCacheList = await CacheTool.getCoverAllFiles();
    coverCache.value = CacheTool.getAllFilesSize(coverCacheList);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(onPressed: () async {
        final r2 = R2Cloud();
        await r2.init();
        SongManager.tempList = await r2.getNewSongList();
        await SongManager.getCloudSongs();
      }),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
        title: AppTheme.w("设置", 20),
        centerTitle: true,
        backgroundColor: AppTheme.darkBlue,
        leading: BackButton(color: Colors.white));
  }

  Widget _buildBody() {
    return Stack(children: [
      Container(color: Color.fromARGB(255, 238, 238, 238)),
      _buildSettingsList()
    ]);
  }

  Widget _buildSettingsList() {
    return Obx(() {
      var cacheTile1 = _cacheTile(
          leadingIcon: Icons.music_note,
          title: "清理音频播放缓存",
          cacheValue: songCache.value,
          cleaning: songCacheCleanging.value,
          onTap: () async {
            songCacheCleanging(true);
            await CacheTool.deleteFiles(songCacheList);
            songCacheCleanging(false);
            songCache(0);
          });
      var cacheTile2 = _cacheTile(
          leadingIcon: Icons.image,
          title: "清理音频封面缓存",
          cacheValue: coverCache.value,
          cleaning: coverCacheCleanging.value,
          onTap: () async {
            coverCacheCleanging(true);
            await CacheTool.deleteFiles(coverCacheList);
            coverCacheCleanging(false);
            coverCache(0);
          });
      return Column(mainAxisSize: MainAxisSize.min, children: [
        cacheTile1,
        cacheTile2,
        _cloudSongsTile(),
        _cloudSongsTile2()
      ])
          .color(Colors.white)
          .clipRRect(all: 10)
          .padding(horizontal: 10.w)
          .padding(top: 10.h);
    });
  }

  Widget _cacheTile(
      {required IconData leadingIcon,
      required String title,
      required int cacheValue,
      required bool cleaning,
      required Function() onTap}) {
    return cleaning
        ? loadC()
        : ListTile(
            leading: AppTheme.nI(leadingIcon, Colors.black, 20),
            title: AppTheme.bk(title, 16),
            trailing: AppTheme.bk(filesize(cacheValue), 16),
            onTap: onTap,
          );
  }

  Widget _cloudSongsTile() {
    return ListTile(
      leading: AppTheme.nI(Icons.cloud, Colors.black, 20),
      title: AppTheme.bk("获取云歌曲", 16),
      trailing: Obx(() {
        return AppTheme.bk(SongManager.playlist.length.toString(), 16);
      }),
      onTap: () async {
        Global.t.p();
        await SongManager.clear();
        await Global.cloudInit();
        Global.t.cancel();
      },
    );
  }

  Widget _cloudSongsTile2() {
    return ListTile(
      leading: AppTheme.nI(Icons.cloud, Colors.black, 20),
      title: AppTheme.bk("获取更新歌曲", 16),
      trailing: AppTheme.bk(SongManager.tempList.length.toString(), 16),
      onTap: () async {
        Global.t.p();
        final r2 = R2Cloud();
        await r2.init();
        SongManager.tempList = await r2.getNewSongList();
        setState(() {});
        await SongManager.getCloudSongs();
        setState(() {});
        Global.t.cancel();
      },
    );
  }
}
