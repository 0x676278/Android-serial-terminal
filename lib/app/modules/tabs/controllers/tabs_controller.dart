import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../terminal/views/terminal_view.dart';
import '../../terminal/views/connection_settings_view.dart';

class TabsController extends GetxController {
  RxInt currentIndex = 0.obs;
  PageController pageController = PageController(initialPage: 0);
  
  final List<Widget> pages = const [
    TerminalView(),
    ConnectionSettingsView(),
  ];
  
  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }

  void setCurrentIndex(int index) {
    currentIndex.value = index;
    pageController.jumpToPage(index);
  }
}
