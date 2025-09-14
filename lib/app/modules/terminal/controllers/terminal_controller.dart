import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../services/usb_serial_service.dart';

class TerminalController extends GetxController {
  final UsbSerialService _usbService = Get.find<UsbSerialService>();
  
  // 输入相关
  final RxString inputText = ''.obs;
  final RxString currentLine = ''.obs;
  final RxInt cursorPosition = 0.obs;
  
  // 终端显示
  final RxList<String> displayLines = <String>[].obs;
  // 滚动控制器
  late ScrollController scrollController;
  
  // 自定义按键
  final RxList<Map<String, String>> customButtons = <Map<String, String>>[].obs;
  final RxInt maxCustomButtons = 8.obs;
  
  // 设置相关
  final RxBool showSettings = false.obs;
  final RxBool autoScroll = true.obs;
  final RxInt fontSize = 14.obs;
  final RxString fontFamily = 'monospace'.obs;
  
  // 键盘状态
  final RxBool ctrlPressed = false.obs;
  final RxBool shiftPressed = false.obs;
  final RxBool altPressed = false.obs;
  
  @override
  void onInit() {
    super.onInit();
    scrollController = ScrollController();
    _loadSettings();
    _loadCustomButtons();
    _setupUsbServiceListener();
  }
  
  @override
  void onClose() {
    _saveSettings();
    _saveCustomButtons();
    super.onClose();
  }
  
  // 设置USB服务监听
  void _setupUsbServiceListener() {
    ever(_usbService.terminalLines, (List<String> lines) {
      displayLines.assignAll(lines);
      _scrollToBottom();
    });
  }
  
  // 处理键盘输入
  void handleKeyInput(String key) {
    // 即使没有连接也处理键盘输入，用于测试
    print('控制器处理按键: $key');
    
    switch (key) {
      case 'Enter':
        _sendCurrentLine();
        break;
      case 'Backspace':
        _handleBackspace();
        break;
      case 'Tab':
        _handleTab();
        break;
      case 'Escape':
        _handleEscape();
        break;
      case 'ArrowUp':
        _handleArrowUp();
        break;
      case 'ArrowDown':
        _handleArrowDown();
        break;
      case 'ArrowLeft':
        _handleArrowLeft();
        break;
      case 'ArrowRight':
        _handleArrowRight();
        break;
      case 'Ctrl':
        ctrlPressed.value = !ctrlPressed.value;
        break;
      case 'Shift':
        shiftPressed.value = !shiftPressed.value;
        break;
      case 'Alt':
        altPressed.value = !altPressed.value;
        break;
      default:
        _addCharacter(key);
        break;
    }
  }
  
  // 添加字符
  void _addCharacter(String char) {
    if (char.length == 1) {
      String newLine = currentLine.value;
      int pos = cursorPosition.value;
      
      if (pos >= newLine.length) {
        newLine += char;
      } else {
        newLine = newLine.substring(0, pos) + char + newLine.substring(pos);
      }
      
      currentLine.value = newLine;
      cursorPosition.value = pos + 1;
      
      // 确保光标可见
      _ensureCursorVisible();
    }
  }
  
  // 处理退格键
  void _handleBackspace() {
    if (cursorPosition.value > 0) {
      String newLine = currentLine.value;
      int pos = cursorPosition.value;
      
      newLine = newLine.substring(0, pos - 1) + newLine.substring(pos);
      currentLine.value = newLine;
      cursorPosition.value = pos - 1;
      
      // 确保光标可见
      _ensureCursorVisible();
    }
  }
  
  // 处理Tab键
  void _handleTab() {
    _addCharacter('\t');
  }
  
  // 处理Escape键
  void _handleEscape() {
    _addCharacter('\x1B'); // ESC字符
  }
  
  // 处理方向键
  void _handleArrowUp() {
    // 可以在这里实现命令历史功能
    _addCharacter('\x1B[A'); // ANSI上箭头
  }
  
  void _handleArrowDown() {
    _addCharacter('\x1B[B'); // ANSI下箭头
  }
  
  void _handleArrowLeft() {
    if (cursorPosition.value > 0) {
      cursorPosition.value--;
      _ensureCursorVisible();
    }
  }
  
  void _handleArrowRight() {
    if (cursorPosition.value < currentLine.value.length) {
      cursorPosition.value++;
      _ensureCursorVisible();
    }
  }
  
  // 发送当前行
  void _sendCurrentLine() {
    if (currentLine.value.isNotEmpty) {
      // 添加到显示行中
      displayLines.add(r'>> ' + currentLine.value);
      if (_usbService.isConnected.value) {
        _usbService.sendData('${currentLine.value}\n');
      }
      currentLine.value = '';
      cursorPosition.value = 0;
    } else {
      displayLines.add(r'>> ');
      if (_usbService.isConnected.value) {
        _usbService.sendData('\n');
      }
    }
    _scrollToBottom();
  }
  
  // 滚动到底部
  void _scrollToBottom() {
    if (scrollController.hasClients) {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
      );
    }
  }
  
  // 确保光标可见
  void _ensureCursorVisible() {
    _scrollToBottom();
  }
  
  // 发送自定义按键内容
  void sendCustomButton(int index) {
    if (index < customButtons.length) {
      String content = customButtons[index]['content'] ?? '';
      _usbService.sendData(content);
    }
  }
  
  // 添加自定义按键
  void addCustomButton(String name, String content) {
    if (customButtons.length < maxCustomButtons.value) {
      customButtons.add({
        'name': name,
        'content': content,
      });
      _saveCustomButtons();
    }
  }
  
  // 编辑自定义按键
  void editCustomButton(int index, String name, String content) {
    if (index < customButtons.length) {
      customButtons[index] = {
        'name': name,
        'content': content,
      };
      _saveCustomButtons();
    }
  }
  
  // 删除自定义按键
  void deleteCustomButton(int index) {
    if (index < customButtons.length) {
      customButtons.removeAt(index);
      _saveCustomButtons();
    }
  }
  
  // 清空终端
  void clearTerminal() {
    _usbService.clearTerminal();
    displayLines.clear();
    _scrollToBottom();
  }
  
  // 滚动终端
  void scrollTerminal(int direction) {
    if (scrollController.hasClients) {
      double currentOffset = scrollController.offset;
      double newOffset = currentOffset + (direction * 50.0);
      
      if (newOffset >= 0 && newOffset <= scrollController.position.maxScrollExtent) {
        scrollController.animateTo(
          newOffset,
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeOut,
        );
      }
    }
  }
  
  // 设置字体大小
  void setFontSize(int size) {
    fontSize.value = size;
    _saveSettings();
  }
  
  // 设置字体
  void setFontFamily(String family) {
    fontFamily.value = family;
    _saveSettings();
  }
  
  // 切换自动滚动
  void toggleAutoScroll() {
    autoScroll.value = !autoScroll.value;
    _saveSettings();
  }
  
  // 显示/隐藏设置
  void toggleSettings() {
    showSettings.value = !showSettings.value;
  }
  
  // 加载设置
  Future<void> _loadSettings() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      fontSize.value = prefs.getInt('fontSize') ?? 14;
      fontFamily.value = prefs.getString('fontFamily') ?? 'monospace';
      autoScroll.value = prefs.getBool('autoScroll') ?? true;
    } catch (e) {
      print('加载设置失败: $e');
    }
  }
  
  // 保存设置
  Future<void> _saveSettings() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setInt('fontSize', fontSize.value);
      await prefs.setString('fontFamily', fontFamily.value);
      await prefs.setBool('autoScroll', autoScroll.value);
    } catch (e) {
      print('保存设置失败: $e');
    }
  }
  
  // 加载自定义按键
  Future<void> _loadCustomButtons() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String>? buttonNames = prefs.getStringList('customButtonNames');
      List<String>? buttonContents = prefs.getStringList('customButtonContents');
      
      if (buttonNames != null && buttonContents != null) {
        customButtons.clear();
        for (int i = 0; i < buttonNames.length && i < buttonContents.length; i++) {
          customButtons.add({
            'name': buttonNames[i],
            'content': buttonContents[i],
          });
        }
      }
    } catch (e) {
      print('加载自定义按键失败: $e');
    }
  }
  
  // 保存自定义按键
  Future<void> _saveCustomButtons() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String> names = customButtons.map((btn) => btn['name']!).toList();
      List<String> contents = customButtons.map((btn) => btn['content']!).toList();
      
      await prefs.setStringList('customButtonNames', names);
      await prefs.setStringList('customButtonContents', contents);
    } catch (e) {
      print('保存自定义按键失败: $e');
    }
  }
  
  // 获取当前终端状态
  Map<String, dynamic> getTerminalStatus() {
    return {
      'isConnected': _usbService.isConnected.value,
      'currentLine': currentLine.value,
      'cursorPosition': cursorPosition.value,
      'displayLinesCount': displayLines.length,
      'scrollOffset': scrollController.hasClients ? scrollController.offset : 0.0,
      'customButtonsCount': customButtons.length,
    };
  }
}
