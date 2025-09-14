import 'package:get/get.dart';
import '../../../services/usb_serial_service.dart';
import '../controllers/terminal_controller.dart';

class TerminalBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UsbSerialService>(() => UsbSerialService());
    Get.lazyPut<TerminalController>(() => TerminalController());
  }
}
