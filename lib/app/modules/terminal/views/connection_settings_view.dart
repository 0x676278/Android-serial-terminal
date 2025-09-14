import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../services/usb_serial_service.dart';

class ConnectionSettingsView extends GetView<UsbSerialService> {
  const ConnectionSettingsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2D2D2D),
        foregroundColor: Colors.white,
        title: Text(
          'USB串口设置',
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, size: 20.sp),
          onPressed: () => Get.back(),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDeviceSelection(),
            SizedBox(height: 24.h),
            _buildSerialSettings(),
            SizedBox(height: 24.h),
            _buildConnectionButtons(),
          ],
        ),
      ),
    );
  }


  Widget _buildDeviceSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '选择设备',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            IconButton(
              icon: Icon(Icons.refresh, size: 24.sp),
              onPressed: () => controller.refreshDevices(),
              color: const Color(0xFF2196F3),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Obx(() => Container(
          width: double.infinity,
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: const Color(0xFF2D2D2D),
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: const Color(0xFF404040)),
          ),
          child: controller.availableDevices.isEmpty
              ? Text(
                  '正在搜索设备...',
                  style: TextStyle(color: Colors.grey[400], fontSize: 14.sp),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: controller.availableDevices.length,
                  itemBuilder: (context, index) {
                    String device = controller.availableDevices[index];
                    return ListTile(
                      title: Text(
                        device,
                        style: TextStyle(color: Colors.white, fontSize: 14.sp),
                        overflow: TextOverflow.ellipsis,
                      ),
                      leading: Icon(
                        Icons.usb,
                        color: device.contains('未找到') || device.contains('失败')
                            ? Colors.red
                            : Colors.green,
                      ),
                      onTap: device.contains('未找到') || device.contains('失败')
                          ? null
                          : () => _connectToDevice(index),
                    );
                  },
                ),
        )),
        SizedBox(height: 8.h),
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: () => controller.refreshDevices(),
              icon: const Icon(Icons.refresh),
              label: const Text('刷新设备'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2196F3),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSerialSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '串口设置',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12.h),
        _buildSettingRow('波特率', _buildBaudRateSelector()),
        SizedBox(height: 16.h),
        _buildSettingRow('数据位', _buildDataBitsSelector()),
        SizedBox(height: 16.h),
        _buildSettingRow('停止位', _buildStopBitsSelector()),
        SizedBox(height: 16.h),
        _buildSettingRow('校验位', _buildParitySelector()),
      ],
    );
  }

  Widget _buildSettingRow(String label, Widget child) {
    return Row(
      children: [
        SizedBox(
          width: 80.w,
          child: Text(
            label,
            style: TextStyle(color: Colors.white, fontSize: 14.sp),
          ),
        ),
        Expanded(child: child),
      ],
    );
  }

  Widget _buildBaudRateSelector() {
    return Obx(() => DropdownButton<int>(
      value: controller.baudRate.value,
      isExpanded: true,
      dropdownColor: const Color(0xFF2D2D2D),
      style: TextStyle(color: Colors.white, fontSize: 14.sp),
      items: controller.commonBaudRates.map((rate) {
        return DropdownMenuItem(
          value: rate,
          child: Text('$rate'),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          controller.setBaudRate(value);
        }
      },
    ));
  }

  Widget _buildDataBitsSelector() {
    return Obx(() => DropdownButton<int>(
      value: controller.dataBits.value,
      isExpanded: true,
      dropdownColor: const Color(0xFF2D2D2D),
      style: TextStyle(color: Colors.white, fontSize: 14.sp),
      items: [5, 6, 7, 8].map((bits) {
        return DropdownMenuItem(
          value: bits,
          child: Text('$bits'),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          controller.setDataBits(value);
        }
      },
    ));
  }

  Widget _buildStopBitsSelector() {
    return Obx(() => DropdownButton<int>(
      value: controller.stopBits.value,
      isExpanded: true,
      dropdownColor: const Color(0xFF2D2D2D),
      style: TextStyle(color: Colors.white, fontSize: 14.sp),
      items: [1, 2].map((bits) {
        return DropdownMenuItem(
          value: bits,
          child: Text('$bits'),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          controller.setStopBits(value);
        }
      },
    ));
  }

  Widget _buildParitySelector() {
    return Obx(() => DropdownButton<int>(
      value: controller.parity.value,
      isExpanded: true,
      dropdownColor: const Color(0xFF2D2D2D),
      style: TextStyle(color: Colors.white, fontSize: 14.sp),
      items: [
        DropdownMenuItem(value: 0, child: Text('无')),
        DropdownMenuItem(value: 1, child: Text('奇校验')),
        DropdownMenuItem(value: 2, child: Text('偶校验')),
      ],
      onChanged: (value) {
        if (value != null) {
          controller.setParity(value);
        }
      },
    ));
  }

  Widget _buildConnectionButtons() {
    return Obx(() => Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: controller.isConnected.value
                ? () => controller.disconnect()
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF44336),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 12.h),
            ),
            child: Text(
              '断开连接',
              style: TextStyle(fontSize: 16.sp),
            ),
          ),
        ),
        SizedBox(height: 12.h),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: controller.isConnected.value
                ? null
                : () => _showDeviceSelectionDialog(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 12.h),
            ),
            child: Text(
              '连接设备',
              style: TextStyle(fontSize: 16.sp),
            ),
          ),
        ),
      ],
    ));
  }

  void _connectToDevice(int deviceIndex) async {
    bool success = await controller.connectDevice(deviceIndex);
    if (success) {
      Get.back();
      Get.snackbar(
        '连接成功',
        '设备已连接',
        backgroundColor: const Color(0xFF4CAF50),
        colorText: Colors.white,
      );
    } else {
      Get.snackbar(
        '连接失败',
        '无法连接到设备',
        backgroundColor: const Color(0xFFF44336),
        colorText: Colors.white,
      );
    }
  }

  void _showDeviceSelectionDialog() {
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF2D2D2D),
        title: Text(
          '选择设备',
          style: TextStyle(color: Colors.white, fontSize: 16.sp),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Obx(() => ListView.builder(
            shrinkWrap: true,
            itemCount: controller.availableDevices.length,
            itemBuilder: (context, index) {
              String device = controller.availableDevices[index];
              return ListTile(
                title: Text(
                  device,
                  style: TextStyle(color: Colors.white, fontSize: 14.sp),
                ),
                leading: Icon(
                  Icons.usb,
                  color: device.contains('未找到') || device.contains('失败')
                      ? Colors.red
                      : Colors.green,
                ),
                onTap: device.contains('未找到') || device.contains('失败')
                    ? null
                    : () {
                        Get.back();
                        _connectToDevice(index);
                      },
              );
            },
          )),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('取消', style: TextStyle(color: Colors.grey[400])),
          ),
        ],
      ),
    );
  }
}
