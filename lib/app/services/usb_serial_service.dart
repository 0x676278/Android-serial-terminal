import 'dart:async';
import 'dart:typed_data';
import 'package:usb_serial/usb_serial.dart';
import 'package:get/get.dart';

class UsbSerialService extends GetxService {
  static UsbSerialService get to => Get.find();
  
  // 串口设备
  UsbPort? _port;
  StreamSubscription<Uint8List>? _subscription;
  
  // 状态管理
  final RxBool isConnected = false.obs;
  final RxBool isConnecting = false.obs;
  final RxString connectionStatus = '未连接'.obs;
  final RxList<String> availableDevices = <String>[].obs;
  
  // 串口配置
  final RxInt baudRate = 9600.obs;
  final RxInt dataBits = 8.obs;
  final RxInt stopBits = 1.obs;
  final RxInt parity = 0.obs; // 0: None, 1: Odd, 2: Even
  
  // 数据流
  final RxString receivedData = ''.obs;
  final RxList<String> terminalLines = <String>[].obs;
  
  // 常用波特率选项
  final List<int> commonBaudRates = [
    300, 600, 1200, 2400, 4800, 9600, 14400, 19200, 
    28800, 38400, 57600, 115200, 230400, 460800, 921600
  ];
  
  @override
  void onInit() {
    super.onInit();
    _requestPermissions();
  }
  
  @override
  void onClose() {
    disconnect();
    super.onClose();
  }
  
  // 请求USB权限
  Future<void> _requestPermissions() async {
    try {
      // 这里可以添加权限请求逻辑
      await refreshDevices();
    } catch (e) {
      print('权限请求失败: $e');
    }
  }
  
  // 刷新可用设备列表
  Future<void> refreshDevices() async {
    try {
      List<UsbDevice> devices = await UsbSerial.listDevices();
      availableDevices.clear();
      
      for (var device in devices) {
        // 过滤出串口设备（如CH340）
        if (device.productName?.toLowerCase().contains('ch340') == true ||
            device.productName?.toLowerCase().contains('serial') == true ||
            device.productName?.toLowerCase().contains('usb') == true) {
          availableDevices.add('${device.productName} (${device.vid}:${device.pid})');
        }
      }
      
      if (availableDevices.isEmpty) {
        availableDevices.add('未找到USB串口设备');
      }
    } catch (e) {
      print('刷新设备列表失败: $e');
      availableDevices.clear();
      availableDevices.add('刷新设备失败: $e');
    }
  }
  
  // 连接设备
  Future<bool> connectDevice(int deviceIndex) async {
    if (isConnecting.value) return false;
    
    try {
      isConnecting.value = true;
      connectionStatus.value = '正在连接...';
      
      List<UsbDevice> devices = await UsbSerial.listDevices();
      if (deviceIndex >= devices.length) {
        connectionStatus.value = '设备索引无效';
        return false;
      }
      
      UsbDevice device = devices[deviceIndex];
      _port = await UsbSerial.createFromDeviceId(device.deviceId);
      
      if (_port == null) {
        connectionStatus.value = '无法创建设备连接';
        return false;
      }
      
      bool openResult = await _port!.open();
      if (!openResult) {
        connectionStatus.value = '无法打开设备';
        return false;
      }
      
      // 配置串口参数
      await _port!.setDTR(true);
      await _port!.setRTS(true);
      await _port!.setPortParameters(
        baudRate.value,
        dataBits.value,
        stopBits.value,
        parity.value,
      );
      
      // 开始监听数据
      _subscription = _port!.inputStream?.listen(
        _onDataReceived,
        onError: _onError,
        onDone: _onDisconnected,
      );
      
      isConnected.value = true;
      connectionStatus.value = '已连接';
      return true;
      
    } catch (e) {
      connectionStatus.value = '连接失败: $e';
      print('连接设备失败: $e');
      return false;
    } finally {
      isConnecting.value = false;
    }
  }
  
  // 断开连接
  Future<void> disconnect() async {
    try {
      await _subscription?.cancel();
      await _port?.close();
      _port = null;
      _subscription = null;
      
      isConnected.value = false;
      connectionStatus.value = '已断开';
    } catch (e) {
      print('断开连接失败: $e');
    }
  }
  
  // 发送数据
  Future<bool> sendData(String data) async {
    if (!isConnected.value || _port == null) {
      return false;
    }
    
    try {
      Uint8List bytes = Uint8List.fromList(data.codeUnits);
      await _port!.write(bytes);
      return true;
    } catch (e) {
      print('发送数据失败: $e');
      return false;
    }
  }
  
  // 发送字节数据
  Future<bool> sendBytes(List<int> bytes) async {
    if (!isConnected.value || _port == null) {
      return false;
    }
    
    try {
      Uint8List data = Uint8List.fromList(bytes);
      await _port!.write(data);
      return true;
    } catch (e) {
      print('发送字节数据失败: $e');
      return false;
    }
  }
  
  // 数据接收回调
  void _onDataReceived(Uint8List data) {
    String received = String.fromCharCodes(data);
    receivedData.value += received;
    
    // 按行分割并添加到终端显示
    List<String> lines = received.split('\n');
    for (int i = 0; i < lines.length - 1; i++) {
      terminalLines.add(lines[i]);
    }
    
    // 如果最后一行不为空，保留在receivedData中等待更多数据
    if (lines.isNotEmpty && lines.last.isNotEmpty) {
      receivedData.value = lines.last;
    } else {
      receivedData.value = '';
    }
    
    // 限制终端行数，避免内存过多占用
    if (terminalLines.length > 1000) {
      terminalLines.removeRange(0, terminalLines.length - 800);
    }
  }
  
  // 错误回调
  void _onError(error) {
    print('串口错误: $error');
    connectionStatus.value = '连接错误: $error';
    isConnected.value = false;
  }
  
  // 断开回调
  void _onDisconnected() {
    print('设备断开连接');
    isConnected.value = false;
    connectionStatus.value = '设备已断开';
  }
  
  // 清空终端
  void clearTerminal() {
    terminalLines.clear();
    receivedData.value = '';
  }
  
  // 设置波特率
  void setBaudRate(int rate) {
    baudRate.value = rate;
  }
  
  // 设置数据位
  void setDataBits(int bits) {
    dataBits.value = bits;
  }
  
  // 设置停止位
  void setStopBits(int bits) {
    stopBits.value = bits;
  }
  
  // 设置校验位
  void setParity(int parityType) {
    parity.value = parityType;
  }
  
  // 获取当前配置信息
  Map<String, dynamic> getConnectionInfo() {
    return {
      'isConnected': isConnected.value,
      'baudRate': baudRate.value,
      'dataBits': dataBits.value,
      'stopBits': stopBits.value,
      'parity': parity.value,
      'deviceCount': availableDevices.length,
    };
  }
}
