import 'dart:io';

import 'package:path_provider/path_provider.dart';

class AppConfig {
  static Future<Directory> getAppCacheDir() async {
    return await getTemporaryDirectory();
  }

  static String endPoint =
      "bc849e61e1571b67c8bdfc9d40583fdb.r2.cloudflarestorage.com";
  static String accessKey = "42dd92f4685141e7edcff105c9b37f8b";
  static String secretKey =
      "914d44c6b2a5df9b9d9ee5d9d0209673d6607b24421491f9fea1dc561b70e891";
  static String r2Token = "rkGr5-4i5ZPg9uleIgw9I5RCYQkw62TKgaz7pVJJ";
}
