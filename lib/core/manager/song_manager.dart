import 'dart:async';
import 'dart:math';

import 'package:audio_service/audio_service.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:music/common/global.dart';
import 'package:music/core/models/enums.dart';
import 'package:music/core/models/song_model.dart';
import 'package:music/utils/cache_tools.dart';
import 'package:music/utils/music_tools.dart';

class SongManager {
  static SongManager? _instance;
  static SongManager get instance => _instance ??= SongManager();

  static final dataBox = Hive.box("data");
  static late final Box<SongModel> songBox;

  static final playMode = PlayMode.loop.obs;
  static final playlist = <SongModel>[].obs;
  static final currentIndex = 0.obs;
  static final nowSongModel = SongModel().obs;
  static List<SongModel> tempList = [];
  static int nextShuffleIndex = -1;

  static AudioPlayer? get player => nowSongModel.value.player;

  static Future<void> init() async {
    songBox = await Hive.openBox('songs');
    playMode.value = PlayMode.values[dataBox.get("playMode") ?? 0];
    playlist.value = songBox.values.toList().cast<SongModel>();
    Global.log.d("歌单初始化,获取缓存歌单：${playlist.length}");
  }

  static void songInit() {
    if (playlist.isEmpty) {
      Global.log.d("没有歌曲");
      return;
    }
    nowSongModel.value = playlist.first;
    if (playMode.value == PlayMode.shuffle) {
      nextShuffleIndex = Random().nextInt(playlist.length);
    }
    updatePlayingWindow();
  }

  static Future<void> getCloudSongs() async {
    if (tempList.isEmpty) return;
    Global.log.d("开始转换云歌曲模型");
    for (var model in tempList) {
      final musicPath = await cloudMusicToPath(model.url, model.name);
      if (musicPath.isEmpty) {
        Global.log.e("${model.name} 下载失败");
        continue;
      }
      final tag = await readMusicData(musicPath);
      model
        ..songPath = musicPath
        ..name = tag.title ?? model.name
        ..artist = tag.artist ?? "未知"
        ..coverData = tag.pictures.isEmpty ? [] : tag.pictures.first.imageData;
      await model.cacheCover();
      if (!playlist.contains(model)) {
        playlist.add(model);
      }
      if (!songBox.values.toList().contains(model)) {
        songBox.add(model);
      }
    }
    Global.log.d("云歌曲模型转换完成");
    tempList.clear();
  }

  static void changeSong(SongModel model) {
    player?.pause();
    currentIndex.value = playlist.indexOf(model);
    nowSongModel.value = playlist[currentIndex.value];
    updatePlayingWindow();
  }

  static Future<void> startPlay() async {
    final model = nowSongModel.value;
    await model.init();
    await model.player?.seek(Duration.zero);
    await model.player?.resume();
    Global.audioHandler?.playMediaItem(MediaItem(
      id: model.url,
      title: model.name,
      artist: model.artist,
    ));
    Global.audioHandler?.play();
    nowSongModel.value.cacheSong();
    Global.log.d("播放: ${nowSongModel.value.name}");
  }

  static void previous() {
    player?.pause();
    updateSongAndWindow(false);
    updatePlayingWindow();
  }

  static void next() {
    player?.pause();
    if (playMode.value == PlayMode.shuffle && nextShuffleIndex != -1) {
      currentIndex.value = nextShuffleIndex;
      nowSongModel.value = playlist[currentIndex.value];
      if (playMode.value == PlayMode.shuffle) {
        nextShuffleIndex = Random().nextInt(playlist.length);
      }
    } else {
      updateSongAndWindow(true);
    }
    updatePlayingWindow();
  }

  static void updateSongAndWindow(bool isNext) {
    if (playMode.value == PlayMode.shuffle && nextShuffleIndex == -1) {
      nextShuffleIndex = Random().nextInt(playlist.length);
    }
    switch (playMode.value) {
      case PlayMode.shuffle:
        currentIndex.value = nextShuffleIndex;
        nextShuffleIndex = Random().nextInt(playlist.length);
        break;
      case PlayMode.loop:
        currentIndex.value =
            (currentIndex.value + (isNext ? 1 : -1)) % playlist.length;
        if (currentIndex.value < 0) currentIndex.value += playlist.length;
        break;
      case PlayMode.single:
        if (!isNext) {
          player?.seek(Duration.zero);
          return;
        }
        break;
    }
    nowSongModel.value = playlist[currentIndex.value];
  }

  static Future<void> updatePlayingWindow() async {
    int prevIndex = (currentIndex.value - 1) % playlist.length;
    if (prevIndex < 0) prevIndex += playlist.length;
    int nextIndex;
    if (playMode.value == PlayMode.shuffle && nextShuffleIndex != -1) {
      nextIndex = nextShuffleIndex;
    } else {
      nextIndex = (currentIndex.value + 1) % playlist.length;
    }
    for (int i = 0; i < playlist.length; i++) {
      if (i != currentIndex.value && i != prevIndex && i != nextIndex) {
        playlist[i].disposePlayer();
      }
    }
    if (playMode.value != PlayMode.single) {
      playlist[prevIndex].init();
      playlist[nextIndex].init();
    }
    if (playMode.value != PlayMode.single || currentIndex.value != nextIndex) {
      await startPlay();
    }
  }

  static void changePlayMode() {
    final mode = playMode.value;
    switch (mode) {
      case PlayMode.loop:
        playMode.value = PlayMode.shuffle;
        break;
      case PlayMode.shuffle:
        playMode.value = PlayMode.single;
        break;
      case PlayMode.single:
        playMode.value = PlayMode.loop;
        break;
    }

    if (playMode.value == PlayMode.shuffle) {
      nextShuffleIndex = Random().nextInt(playlist.length);
    } else {
      nextShuffleIndex = -1;
    }

    dataBox.put("playMode", playMode.value.index);
    Global.log.d("当前播放模式:${playMode.value}");
  }

  static void clear() {
    tempList.clear();
    currentIndex(0);
    nowSongModel(SongModel());
    playlist.clear();
    songBox.clear();
    Global.log.d("歌单清空");
  }

  static Future<void> clearSongPath() async {
    final files = await CacheTool.getMusicAllFiles();
    await CacheTool.deleteFiles(files);
    for (var model in playlist) {
      model.songPath = "";
      model.save();
    }
    Global.log.d("清除本地缓存歌曲");
  }

  static List<SongModel> getPendingProcessingSongs() {
    return playlist.where((element) => element.pendingProcessing).toList();
  }
}
