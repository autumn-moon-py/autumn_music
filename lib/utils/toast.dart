import 'package:flutter/cupertino.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:music/widgets/extension_widget.dart';
import 'package:music/widgets/small_widgets.dart';

class Toast {
  final duration = const Duration(seconds: 2);
  final longDuration = const Duration(seconds: 10);

  void p() {
    Get.dialog(loadC(30).center(), barrierDismissible: false);
  }

  void myDialog(Function() onTop,
      {String title = '标题',
      String content = '内容',
      String rthBText = "确定",
      String lthBText = '取消'}) {
    if (Get.isDialogOpen ?? false) return;
    Get.dialog(CupertinoAlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          CupertinoDialogAction(
            child: Text(lthBText),
            onPressed: () => Get.back(),
          ),
          CupertinoDialogAction(
              child: Text(rthBText),
              onPressed: () {
                Get.back();
                onTop();
              })
        ]));
  }

  void e(String text, {bool long = false}) {
    EasyLoading.showError(text, duration: long ? longDuration : duration);
  }

  void t(String text,
      {EasyLoadingToastPosition toastPosition = EasyLoadingToastPosition.center,
      bool long = false}) {
    cancel();
    EasyLoading.showToast(text, duration: long ? longDuration : duration);
  }

  void ct(String text) {
    t(text);
  }

  void tt(String text) {
    t(text, toastPosition: EasyLoadingToastPosition.top);
  }

  void bt(String text) {
    t(text, toastPosition: EasyLoadingToastPosition.bottom);
  }

  void cancel() {
    EasyLoading.dismiss();
    if (Get.isDialogOpen ?? false) Get.back();
  }
}
