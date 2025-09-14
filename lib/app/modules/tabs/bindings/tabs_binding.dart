import 'package:get/get.dart';
import '../controllers/tabs_controller.dart';
import '../../terminal/controllers/terminal_controller.dart';
import '../../../services/usb_serial_service.dart';

class TabsBinding extends Bindings {
  @override
  void dependencies() {
    // 注册USB串口服务
    Get.lazyPut<UsbSerialService>(() => UsbSerialService());
    
    // 注册终端控制器
    Get.lazyPut<TerminalController>(() => TerminalController());
    
    // 注册Tab控制器
    Get.lazyPut<TabsController>(() => TabsController());
  }
}
