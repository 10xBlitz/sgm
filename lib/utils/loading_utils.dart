import 'package:flutter_easyloading/flutter_easyloading.dart';

class LoadingUtils {
  static showLoading() {
    EasyLoading.show(status: 'Loading...');
  }

  static dismissLoading() {
    EasyLoading.dismiss();
  }

  static showError(String message) {
    EasyLoading.showError(message);
  }

  static showSuccess(String message) {
    EasyLoading.showSuccess(message);
  }
}
