import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:music/common/global.dart';
import 'package:music/core/manager/song_manager.dart';
import 'package:music/utils/error_catch.dart';
import 'package:music/utils/music_tools.dart';

part 'song_model.g.dart';

@HiveType(typeId: 0)
class SongModel extends HiveObject {
  @HiveField(0)
  String name = "";

  @HiveField(1)
  String artist = "";

  @HiveField(2)
  String coverPath = "";

  @HiveField(3)
  String songPath = "";

  @HiveField(4)
  String url = "";

  List<int> coverData = [];
  Uint8List coverU8 = Uint8List(0);

  AudioPlayer? player;

  var duration = Duration.zero.obs;
  var position = Duration.zero.obs;

  var isPlaying = false.obs;
  var isLoading = false.obs;
  bool isDisposed = false;
  bool hasError = false;
  bool isInitialized = false;
  bool pendingProcessing = false;
  var isShow = false.obs;

  Future<void> init() async {
    if (isDisposed) {
      Global.log.d("$name 已被释放,重新初始化");
    }
    if (isInitialized) {
      Global.log.d("$name 已初始化");
      return;
    }
    isDisposed = false;
    if (songPath.isNotEmpty && !File(songPath).existsSync()) {
      songPath = '';
      save();
      Global.log.e("$name 缓存音频文件丢失");
    }
    player = AudioPlayer();
    audioListen();
    isLoading(true);
    if (songPath.isNotEmpty) {
      await player
          ?.setSource(DeviceFileSource(songPath))
          .withTimeout()
          .catchError((e) {
        hasError = true;
        Global.log.e("$name 初始化本地音乐异常");
        Global.t.e("$name 初始化失败");
        return e;
      });
    } else if (url.isNotEmpty) {
      await player?.setSource(UrlSource(url)).withTimeout().catchError((e) {
        hasError = true;
        Global.log.e("$name 初始化云音乐异常");
        Global.t.e("$name 初始化失败");
        return e;
      });
    } else {
      Global.log.e("$name 没有播放资源");
    }
    isLoading(false);
    isInitialized = true;
    Global.log.d("$name 初始化完成");
    cacheCover();
  }

  void audioListen() {
    player?.onDurationChanged.listen((newDuration) {
      duration.value = newDuration;
    });
    player?.onPositionChanged.listen((newPosition) {
      position.value = newPosition;
    });
    player?.onPlayerStateChanged.listen((state) {
      isPlaying.value = state == PlayerState.playing;
      if (isPlaying.value) {
        isLoading(false);
        Global.audioHandler?.setPlay();
      } else {
        Global.audioHandler?.setPause();
      }
      Global.log.d("$name 播放状态: $state");
    });
    player?.onPlayerStateChanged.listen((event) {
      bool over = event == PlayerState.completed;
      if (over) {
        SongManager.next();
      }
    });
  }

  void playOrPause() {
    if (isDisposed || hasError || !isInitialized) {
      Global.log.e("$name 已被释放,异常,未初始化");
      isDisposed = false;
      hasError = false;
      init().then((_) {
        playOrPause();
      });
      return;
    }
    isPlaying.value ? player?.pause() : player?.resume();
    isPlaying.toggle();
  }

  Future<void> cacheSong() async {
    if (url.isEmpty || songPath.isNotEmpty) return;
    final path = await cloudMusicToPath(url, name);
    if (File(path).existsSync()) {
      Global.log.d("缓存 $name 成功");
      songPath = path;
      save();
    }
  }

  Future<void> refreshCover() async {
    if (songPath.isEmpty) {
      songPath = await cloudMusicToPath(url, name);
    }
    final tag = await readMusicData(songPath);
    coverData = tag.pictures.isEmpty ? [] : tag.pictures.first.imageData;
    await cacheCover();
    save();
    Global.log.d("刷新封面");
  }

  Future<void> cacheCover() async {
    if (coverData.isEmpty) return;
    final path = await memoryImageToPath(coverData, name);
    if (File(path).existsSync()) {
      coverPath = path;
    }
  }

  void formatCoverDate() {
    if (coverData.isEmpty) return;
    coverU8 = Uint8List.fromList(coverData);
    coverData = [];
    Global.log.d("格式化封面数据成功");
  }

  void mark() {
    if (pendingProcessing) {
      Global.t.t("标记过");
      return;
    }
    pendingProcessing = true;
    save();
    Global.log.d("$name 已标记待处理");
    Global.t.t("已标记");
  }

  void disposePlayer() {
    if (!isDisposed && isInitialized) {
      player?.dispose();
      player = null;
      isDisposed = true;
      isInitialized = false;
      Global.log.d("$name 已释放");
    }
  }

  @override
  operator ==(Object other) {
    return other is SongModel && other.name == name && other.artist == artist;
  }

  @override
  int get hashCode => name.hashCode ^ artist.hashCode;
}
