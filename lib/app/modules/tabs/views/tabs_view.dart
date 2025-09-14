import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../controllers/tabs_controller.dart';

class TabsView extends GetView<TabsController> {
  const TabsView({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      extendBody: true,
      body: SafeArea(
        top: false,
        bottom: false,
        child: PageView(
          controller: controller.pageController,
          children: controller.pages,
          onPageChanged: (index) {
            controller.setCurrentIndex(index);
          },
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF2D2D2D),
          border: Border(top: BorderSide(color: Color(0xFF404040))),
        ),
        child: SafeArea(
          child: BottomNavigationBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            selectedItemColor: const Color(0xFF2196F3),
            unselectedItemColor: Colors.grey[400],
            currentIndex: controller.currentIndex.value,
            type: BottomNavigationBarType.fixed,
            onTap: (index) {
              controller.setCurrentIndex(index);
            },
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.terminal, size: 20.sp),
                label: "终端",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings, size: 20.sp),
                label: "设置",
              ),
            ],
          ),
        ),
      ),
    ));
  }
}
