import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
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
  }
}

extension FutureTimeoutExtension<T> on Future<T> {
  static Duration? timeout;

  Future<T> withTimeout([Duration? timeLimit]) {
    return this.timeout(
      timeLimit ?? timeout ?? const Duration(seconds: 30),
      onTimeout: () => throw TimeoutException(
          'Future operation timed out after ${timeLimit?.inSeconds ?? timeout?.inSeconds ?? 30} seconds'),
    );
  }
}
