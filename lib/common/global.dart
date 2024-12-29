import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background/flutter_background.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:music/core/manager/song_manager.dart';
import 'package:music/core/models/song_model.dart';
import 'package:music/core/service/r2.dart';
import 'package:music/utils/music_tools.dart';
import 'package:music/utils/toast.dart';
import 'package:window_manager/window_manager.dart';

class Global {
  static Global? _instance;
  static Global get instance => _instance ??= Global();

  static final log = MyLogger();
  static final t = Toast();

  static Future<void> init() async {
    WidgetsFlutterBinding.ensureInitialized();
    await windowsInit();
    await Hive.initFlutter();
    Hive.registerAdapter(SongModelAdapter());
    await Hive.openBox("data");
    await audioActionInit();
    await backgroundInit();
    await SongManager.init();
    await SongManager.songInit();
  }

  static Future<void> backgroundInit() async {
    if (!GetPlatform.isAndroid) return;
    final androidConfig = FlutterBackgroundAndroidConfig(
      notificationTitle: "秋月音乐",
      notificationText: "秋月音乐常驻",
      notificationImportance: AndroidNotificationImportance.normal,
      notificationIcon:
          AndroidResource(name: 'background_icon', defType: 'drawable'),
    );
    await FlutterBackground.initialize(androidConfig: androidConfig);
    await FlutterBackground.enableBackgroundExecution();
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

  static Future<void> cloudInit() async {
    final r2 = R2Cloud();
    await r2.init();
    SongManager.tempList = await r2.getSongList();
    await SongManager.getCloudSongs();
  }

  static AudioSession? session;

  static Future<void> audioActionInit() async {
    if (GetPlatform.isDesktop) return;
    session = await AudioSession.instance;
    await session?.configure(AudioSessionConfiguration.music());
    session?.interruptionEventStream.listen((event) {
      if (event.begin) {
        switch (event.type) {
          case AudioInterruptionType.pause:
            SongManager.player?.resume();
            break;
          case AudioInterruptionType.duck:
          case AudioInterruptionType.unknown:
            break;
        }
      } else {
        switch (event.type) {
          case AudioInterruptionType.duck:
            SongManager.player?.pause();
            break;
          case AudioInterruptionType.pause:
            SongManager.player?.resume();
          case AudioInterruptionType.unknown:
            break;
        }
      }
    });
    session?.becomingNoisyEventStream.listen((_) {
      Global.log.d("拔掉耳机,暂停音乐");
      SongManager.player?.pause();
    });
    audioHandler = await AudioService.init(
        builder: () => MyAudioHandler(),
        config: AudioServiceConfig(
            androidNotificationChannelId: 'com.autumn.music.channel.audio',
            androidNotificationChannelName: '秋月音乐'));
  }

  static MyAudioHandler? audioHandler;
}

class MyLogger {
  List<String> logList = [];

  static const key = '秋月';

  void d(String text) {
    logList.add(text);
    debugPrint("$key $text");
  }

  void e(String text) {
    logList.add(text);
    debugPrint("$key error $text");
  }
}
