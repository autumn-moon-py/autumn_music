import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music/common/global.dart';

class GlobalErrorHandler {
  static void init(void Function() cb) {
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      _reportError(details.exception, details.stack);
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      _reportError(error, stack);
      return true;
    };

    runZonedGuarded(() async {
      cb();
    }, (Object error, StackTrace stack) {
      _reportError(error, stack);
    });
  }

  static void _reportError(Object error, StackTrace? stack) {
    Global.log.e("details:$error stack:$stack");
    Global.t.myDialog(() {
      Get.back();
    }, content: error.toString(), title: "异常");
  }
}
