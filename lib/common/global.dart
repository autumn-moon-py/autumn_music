import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background/flutter_background.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:logger/logger.dart';
import 'package:music/core/manager/song_manager.dart';
import 'package:music/core/models/song_model.dart';
import 'package:music/utils/music_tools.dart';
import 'package:music/utils/toast.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:window_manager/window_manager.dart';

class Global {
  static Global? _instance;
  static Global get instance => _instance ??= Global();

  static final log = MyLogger();
  static final t = Toast();

  static MyAudioHandler? audioHandler;

  static String version = "";

  static Future<void> init() async {
    WidgetsFlutterBinding.ensureInitialized();
    await getVersion();
    await windowsInit();
    await Hive.initFlutter();
    Hive.registerAdapter(SongModelAdapter());
    await Hive.openBox("data");
    await audioActionInit();
    await backgroundInit();
    await SongManager.init();
    SongManager.songInit();
  }

  static Future<void> getVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String v = packageInfo.version;
    String n = packageInfo.buildNumber;
    version = v + n;
  }

  static Future<void> backgroundInit() async {
    if (!GetPlatform.isAndroid) return;
    final androidConfig = FlutterBackgroundAndroidConfig(
      notificationTitle: "秋月音乐",
      notificationText: "秋月音乐常驻",
    );
    await FlutterBackground.initialize(androidConfig: androidConfig);
  }

  static Future<void> windowsInit() async {
    if (GetPlatform.isDesktop) {
      await windowManager.ensureInitialized();
      WindowOptions windowOptions = WindowOptions(
        size: Size(344, 768),
        backgroundColor: Colors.transparent,
        skipTaskbar: false,
      );
      windowManager.waitUntilReadyToShow(windowOptions, () async {
        await windowManager.show();
        await windowManager.focus();
      });
    }
  }

  static Future<void> audioActionInit() async {
    if (GetPlatform.isDesktop) return;
    audioHandler = await AudioService.init(
        builder: () => MyAudioHandler(),
        config: AudioServiceConfig(
            androidNotificationChannelId: 'com.autumn.music.channel.audio',
            androidNotificationChannelName: '秋月音乐'));
  }
}

class MyLogger {
  List<String> logList = [];

  static const key = '秋月';
  Logger log = Logger();

  void d(String text) {
    logList.add(text);
    log.d("$key $text");
  }

  void e(String text) {
    logList.add("error: $text");
    log.e("$key error $text");
  }
}
