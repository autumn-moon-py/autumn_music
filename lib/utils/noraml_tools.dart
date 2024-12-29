extension DateTimeExtension on DateTime {
  /// 获取日期字符串
  /// type: 0-"yyyy-MM-dd", 1-"yyyy/MM/dd", 2-"hh:mm:ss",3-"hh:mm"
  String toDateString([int type = 0]) {
    if (type == 2) {
      return "${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}:${second.toString().padLeft(2, '0')}";
    }
    if (type == 3) {
      return "${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}";
    }
    final withKey = type == 0 ? "-" : "";
    return '$year$withKey${month.toString().padLeft(2, '0')}$withKey${day.toString().padLeft(2, '0')}';
  }
}

String filesize(int size, [int precision = 2]) {
  const int kb = 1024;
  const int mb = kb * 1024;
  const int gb = mb * 1024;
  const int tb = gb * 1024;

  if (size < kb) {
    return "$size B";
  } else if (size < mb) {
    return "${(size / kb).toStringAsFixed(precision)} KB";
  } else if (size < gb) {
    return "${(size / mb).toStringAsFixed(precision)} MB";
  } else if (size < tb) {
    return "${(size / gb).toStringAsFixed(precision)} GB";
  } else {
    return "${(size / tb).toStringAsFixed(precision)} TB";
  }
}
