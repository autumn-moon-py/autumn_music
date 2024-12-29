import 'package:dio/dio.dart';
import 'package:minio/minio.dart';
import 'package:music/common/config.dart';
import 'package:music/common/global.dart';
import 'package:music/core/models/song_model.dart';

class R2Cloud {
  final bucket = 'subrecovery';
  final songList = <SongModel>[];
  final prefix = "music/";
  final domain = "r2.subrecovery.top";
  late final Minio minio;

  Future<void> init() async {
    minio = Minio(
        endPoint: AppConfig.endPoint,
        accessKey: AppConfig.accessKey,
        secretKey: AppConfig.secretKey);
  }

  String replaceDomain(String url, String newDomain) {
    Uri uri = Uri.parse(url);
    return Uri(
            scheme: uri.scheme,
            host: newDomain,
            path: uri.path.replaceFirst("/$bucket", ""),
            query: uri.query)
        .toString();
  }

  Future<List<SongModel>> getSongList() async {
    try {
      final objects = await minio.listAllObjects(bucket, prefix: prefix);
      List<SongModel> songList = [];
      for (var object in objects.objects) {
        final String name = object.key ?? '';
        if (!name.contains("mp3")) continue;
        String songUrl = await minio.presignedGetObject(bucket, name);
        songUrl = replaceDomain(songUrl, domain);
        final model = SongModel()
          ..name = name.replaceFirst(".mp3", "").replaceFirst(prefix, "")
          ..url = songUrl;
        songList.add(model);
        Global.log.d("${model.name} 添加成功");
      }
      Global.log.d("获取云歌曲数量:${songList.length}");
      return songList;
    } catch (e) {
      Global.log.e("获取歌曲列表失败: $e");
      return [];
    }
  }

  Future<List<SongModel>> getNewSongList() async {
    List<String> newSongList = [];
    final uptateUrl = "https://r2.subrecovery.top/update.txt";
    final response = await Dio().get(uptateUrl);
    newSongList = response.data.toString().split("\n");
    newSongList = newSongList.map((e) => e.replaceAll("\r", "")).toList();
    if (newSongList.isEmpty) {
      Global.log.e("更新列表为空");
      return [];
    }
    for (var name in newSongList) {
      String songUrl = await minio.presignedGetObject(bucket, name);
      songUrl = replaceDomain(songUrl, domain);
      final model = SongModel()
        ..url = songUrl
        ..name = name.replaceFirst(".mp3", "").replaceFirst(prefix, "");
      songList.add(model);
      Global.log.d("${model.name} 添加成功");
    }
    Global.log.d("获取更新歌曲数量:${songList.length}");
    return songList;
  }
}
