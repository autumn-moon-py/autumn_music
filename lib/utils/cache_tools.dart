import 'dart:io';

import 'package:music/common/config.dart';
import 'package:music/common/global.dart';

class CacheTool {
  static Future<List<FileSystemEntity>> getDirFiles(Directory directory) async {
    if (!directory.existsSync()) return [];
    List<FileSystemEntity> entities = await directory.list().toList();
    return entities;
  }

  static void logFiles(List<File> files) {
    Global.log.d("文件数量:${files.length}");
  }

  static void logDirs(List<Directory> dirs) {
    Global.log.d("文件夹数量:${dirs.length}");
  }

  static List<File> getFilesByFileSystemEntity(
      List<FileSystemEntity> entities) {
    List<File> files = entities.whereType<File>().toList();
    logFiles(files);
    return files;
  }

  static Future<void> deleteFiles(List<File> files) async {
    for (File file in files) {
      await file.delete();
    }
    Global.log.d("删除完成");
  }

  static List<Directory> getDirsByFileSystemEntity(
      List<FileSystemEntity> entities) {
    List<Directory> dirs = entities.whereType<Directory>().toList();
    logDirs(dirs);
    return dirs;
  }

  static Future<List<File>> getCoverAllFiles() async {
    Directory directory = await AppConfig.getAppCacheDir();
    directory = Directory("${directory.path}/cover");
    List<FileSystemEntity> entities = await getDirFiles(directory);
    final allFile = getFilesByFileSystemEntity(entities);
    return allFile;
  }

  static Future<List<File>> getMusicAllFiles() async {
    Directory directory = await AppConfig.getAppCacheDir();
    directory = Directory("${directory.path}/music");
    List<FileSystemEntity> entities = await getDirFiles(directory);
    final allFile = getFilesByFileSystemEntity(entities);
    return allFile;
  }

  static int getAllFilesSize(List<File> files) {
    int size = 0;
    for (File file in files) {
      size += file.lengthSync();
    }
    return size;
  }
}
