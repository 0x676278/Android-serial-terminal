import 'package:get/get.dart';
import '../../../routes/app_pages.dart';

class HomeController extends GetxController {
  
  // 导航到终端页面
  void navigateToTerminal() {
    Get.toNamed(Routes.TERMINAL);
  }
  
  // 导航到设置页面
  void navigateToSettings() {
    Get.toNamed(Routes.CONNECTION_SETTINGS);
  }
}
