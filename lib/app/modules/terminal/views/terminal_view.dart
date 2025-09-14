import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../controllers/terminal_controller.dart';
import '../../../services/usb_serial_service.dart';

class TerminalView extends GetView<TerminalController> {
  const TerminalView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Get.back(); // 系统返回键时返回上一页
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF1E1E1E),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          color: const Color(0xFF1E1E1E),
          child: Focus(
            autofocus: true,
            canRequestFocus: true,
            onKeyEvent: (node, event) {
              if (event is KeyDownEvent) {
                if (_handleKeyEvent(event)) {
                  return KeyEventResult.handled;
                }
              }
              return KeyEventResult.ignored;
            },
            child: GestureDetector(
              onTap: () {
                // 点击终端区域时确保焦点
                FocusScope.of(context).requestFocus(FocusNode());
              },
              child: Column(
                children: [
                  _buildConnectionStatus(),
                  Expanded(
                    flex: 1,
                    child: _buildTerminalDisplay(),
                  ),
                  _buildFunctionKeys(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildConnectionStatus() {
    return Obx(() {
      final usbService = Get.find<UsbSerialService>();
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        color: usbService.isConnected.value
            ? const Color(0xFF4CAF50)
            : const Color(0xFFF44336),
        child: Row(
          children: [
            Icon(
              usbService.isConnected.value ? Icons.usb : Icons.usb_off,
              color: Colors.white,
              size: 16.sp,
            ),
            SizedBox(width: 6.w),
            Text(
              usbService.connectionStatus.value,
              style: TextStyle(
                color: Colors.white,
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            if (usbService.isConnected.value)
              TextButton(
                onPressed: () => usbService.disconnect(),
                style: TextButton.styleFrom(
                  padding:
                  EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  '断开',
                  style: TextStyle(color: Colors.white, fontSize: 10.sp),
                ),
              ),
          ],
        ),
      );
    });
  }

  Widget _buildTerminalDisplay() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF000000),
        border: Border.all(color: const Color(0xFF404040), width: 1),
      ),
      child: Obx(() {
        return SingleChildScrollView(
          controller: controller.scrollController,
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 12.h),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(Get.context!).size.height - 200.h,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...controller.displayLines.map((line) => Text(
                  line,
                  style: TextStyle(
                    color: const Color(0xFF00FF00),
                    fontSize: (controller.fontSize.value + 2).sp,
                    fontFamily: controller.fontFamily.value,
                    height: 1.4,
                  ),
                )),
                _buildCurrentInputLine(),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildCurrentInputLine() {
    return Obx(() {
      String currentLine = controller.currentLine.value;
      int cursorPos = controller.cursorPosition.value;

      return RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: r'>> ',
              style: TextStyle(
                color: const Color(0xFF00FF00),
                fontSize: (controller.fontSize.value + 2).sp,
                fontFamily: controller.fontFamily.value,
                height: 1.4,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextSpan(
              text: currentLine.substring(0, cursorPos),
              style: TextStyle(
                color: const Color(0xFF00FF00),
                fontSize: (controller.fontSize.value + 2).sp,
                fontFamily: controller.fontFamily.value,
                height: 1.4,
              ),
            ),
            TextSpan(
              text: '▊',
              style: TextStyle(
                color: const Color(0xFF00FF00),
                fontSize: (controller.fontSize.value + 2).sp,
                fontFamily: controller.fontFamily.value,
                height: 1.4,
              ),
            ),
            TextSpan(
              text: currentLine.substring(cursorPos),
              style: TextStyle(
                color: const Color(0xFF00FF00),
                fontSize: (controller.fontSize.value + 2).sp,
                fontFamily: controller.fontFamily.value,
                height: 1.4,
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildFunctionKeys() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      decoration: const BoxDecoration(
        color: Color(0xFF2D2D2D),
        border: Border(top: BorderSide(color: Color(0xFF404040), width: 1)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        child: Row(
          children: [
            _buildFunctionKey('Tab', () => controller.handleKeyInput('Tab')),
            SizedBox(width: 2.w),
            _buildFunctionKey('Esc', () => controller.handleKeyInput('Escape')),
            SizedBox(width: 2.w),
            _buildFunctionKey('↑', () => controller.handleKeyInput('ArrowUp')),
            SizedBox(width: 2.w),
            _buildFunctionKey('↓', () => controller.handleKeyInput('ArrowDown')),
            SizedBox(width: 2.w),
            _buildFunctionKey('←', () => controller.handleKeyInput('ArrowLeft')),
            SizedBox(width: 2.w),
            _buildFunctionKey('→', () => controller.handleKeyInput('ArrowRight')),
            SizedBox(width: 2.w),
            _buildFunctionKey('Ctrl', () => controller.handleKeyInput('Ctrl')),
            SizedBox(width: 2.w),
            _buildFunctionKey('Shift', () => controller.handleKeyInput('Shift')),
            SizedBox(width: 2.w),
            _buildFunctionKey('Alt', () => controller.handleKeyInput('Alt')),
            SizedBox(width: 2.w),
            _buildFunctionKey('清空', () => controller.clearTerminal()),
          ],
        ),
      ),
    );
  }

  Widget _buildFunctionKey(String label, VoidCallback onPressed) {
    return Container(
      width: 40.w,
      height: 36.h,
      margin: EdgeInsets.symmetric(horizontal: 2.w),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF404040),
          foregroundColor: Colors.white,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6.r),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  /// 处理键盘事件
  bool _handleKeyEvent(KeyDownEvent event) {
    print('键盘事件: ${event.logicalKey}');

    // 返回键/ESC
    if (event.logicalKey == LogicalKeyboardKey.escape ||
        event.logicalKey == LogicalKeyboardKey.goBack) {
      //Get.back();
      return true;
    }

    String key = '';
    if (event.logicalKey == LogicalKeyboardKey.enter) {
      key = 'Enter';
    } else if (event.logicalKey == LogicalKeyboardKey.backspace) {
      key = 'Backspace';
    } else if (event.logicalKey == LogicalKeyboardKey.tab) {
      key = 'Tab';
    } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      key = 'ArrowUp';
    } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      key = 'ArrowDown';
    } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      key = 'ArrowLeft';
    } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
      key = 'ArrowRight';
    } else if (event.logicalKey == LogicalKeyboardKey.controlLeft ||
        event.logicalKey == LogicalKeyboardKey.controlRight) {
      key = 'Ctrl';
    } else if (event.logicalKey == LogicalKeyboardKey.shiftLeft ||
        event.logicalKey == LogicalKeyboardKey.shiftRight) {
      key = 'Shift';
    } else if (event.logicalKey == LogicalKeyboardKey.altLeft ||
        event.logicalKey == LogicalKeyboardKey.altRight) {
      key = 'Alt';
    } else if (event.character != null && event.character!.isNotEmpty) {
      key = event.character!;
    }

    if (key.isNotEmpty) {
      print('处理按键: $key');
      controller.handleKeyInput(key);
      return true;
    }
    return false;
  }
}
