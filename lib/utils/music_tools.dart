import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:id3tag/id3tag.dart';
import 'package:music/common/config.dart';
import 'package:music/core/manager/song_manager.dart';

Future<ID3Tag> readMusicData(String path) async {
  final parser = ID3TagReader.path(path);
  final ID3Tag tag = parser.readTagSync();
  return tag;
}

Future<String> assetsMusicToPath(String assetsPath, String fileName) async {
  final ByteData fileData = await rootBundle.load(assetsPath);
  final dir = (await AppConfig.getAppCacheDir()).path;
  late Directory musciDir;
  if (GetPlatform.isAndroid) {
    musciDir = Directory("$dir/music");
  } else {
    musciDir = Directory("$dir\\music");
  }
  if (!musciDir.existsSync()) {
    musciDir.createSync();
  }
  late String filePath;
  fileName = fileName.replaceAll(RegExp(r'[\\/:*?"<>|]'), '');
  if (GetPlatform.isAndroid) {
    filePath = '${musciDir.path}/$fileName.mp3';
  } else {
    filePath = '${musciDir.path}\\$fileName.mp3';
  }
  if (File(filePath).existsSync()) return filePath;
  final u8 = fileData.buffer
      .asUint8List(fileData.offsetInBytes, fileData.lengthInBytes);
  final musicFile = File(filePath)..writeAsBytesSync(u8);
  return musicFile.path;
}

Future<String> memoryImageToPath(List<int> bytes, String fileName) async {
  final dir = (await AppConfig.getAppCacheDir()).path;
  late Directory coverDir;
  if (GetPlatform.isAndroid) {
    coverDir = Directory("$dir/cover");
  } else {
    coverDir = Directory("$dir\\cover");
  }
  if (!coverDir.existsSync()) {
    coverDir.createSync();
  }
  late String filePath;
  fileName = fileName.replaceAll(RegExp(r'[\\/:*?"<>|]'), '');
  if (GetPlatform.isAndroid) {
    filePath = '${coverDir.path}/$fileName.png';
  } else {
    filePath = '${coverDir.path}\\$fileName.png';
  }
  if (File(filePath).existsSync()) return filePath;
  final coverFile = File(filePath)..writeAsBytesSync(bytes);
  return coverFile.path;
}

Future<String> cloudMusicToPath(String url, String fileName) async {
  final dio = Dio();
  final dir = await AppConfig.getAppCacheDir();
  late Directory downloadDir;
  if (Platform.isAndroid) {
    downloadDir = Directory("${dir.path}/music");
  } else {
    downloadDir = Directory("${dir.path}\\music");
  }
  if (!downloadDir.existsSync()) {
    downloadDir.createSync();
  }
  late String filePath;
  fileName = fileName.replaceAll(RegExp(r'[\\/:*?"<>|]'), '');
  if (Platform.isAndroid) {
    filePath = '${downloadDir.path}/$fileName';
  } else {
    filePath = '${downloadDir.path}\\$fileName';
  }
  if (File(filePath).existsSync()) return filePath;

  try {
    final response = await dio.download(url, filePath);
    if (response.statusCode == 200) {
      return filePath;
    }
  } catch (_) {}
  return "";
}

class MyAudioHandler extends BaseAudioHandler {
  void _updateState(PlaybackState state) {
    playbackState.add(state);
  }

  List<MediaControl> _getControls(bool playing) {
    return [
      MediaControl.skipToPrevious,
      if (playing) MediaControl.pause else MediaControl.play,
      MediaControl.skipToNext,
    ];
  }

  @override
  Future<void> playMediaItem(MediaItem mediaItem) async {
    this.mediaItem.add(mediaItem);
    setPlay();
  }

  @override
  Future<void> play() async {
    SongManager.player?.resume();
  }

  @override
  Future<void> pause() async {
    SongManager.player?.pause();
  }

  void setPlay() {
    _updateState(PlaybackState(
      controls: _getControls(true),
      processingState: AudioProcessingState.ready,
      playing: true,
    ));
  }

  void setPause() {
    _updateState(PlaybackState(
      controls: _getControls(false),
      processingState: AudioProcessingState.ready,
      playing: false,
    ));
  }

  @override
  Future<void> skipToNext() async {
    SongManager.next();
  }

  @override
  Future<void> skipToPrevious() async {
    SongManager.previous();
  }
}
