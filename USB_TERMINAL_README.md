# USB串口终端应用

这是一个基于Flutter和GetX的USB串口终端应用，支持连接CH340等USB串口设备，提供完整的终端功能。

## 功能特性

### 🔌 USB串口连接
- 支持CH340、CP2102等常见USB转串口芯片
- 自动检测和列出可用设备
- 支持多种波特率设置（300-921600）
- 可配置数据位、停止位、校验位

### 💻 终端功能
- 实时显示串口接收数据
- 支持键盘输入（Enter发送）
- 支持特殊按键：Tab、Esc、方向键、Ctrl等
- 自动滚动和手动滚动
- 清空终端功能

### 🎛️ 自定义按键
- 底部自定义按键栏
- 长按编辑按键名称和发送内容
- 支持最多8个自定义按键
- 点击自动发送对应内容

### 🎨 界面设计
- 暗色调主题，护眼设计
- 绿色终端字体，经典终端风格
- 响应式布局，适配不同屏幕
- 现代化Material Design界面

## 技术架构

### MVC架构
- **Model**: UsbSerialService - 处理USB串口通信
- **View**: TerminalView, ConnectionSettingsView - UI界面
- **Controller**: TerminalController - 业务逻辑控制

### 依赖包
- `get: ^4.6.6` - 状态管理和路由
- `usb_serial: ^0.5.0` - USB串口通信
- `permission_handler: ^11.3.1` - 权限管理
- `shared_preferences: ^2.2.2` - 本地存储
- `flutter_screenutil: ^5.5.4` - 屏幕适配

## 使用说明

### 1. 连接设备
1. 点击右上角USB图标进入连接设置
2. 点击"刷新设备"搜索可用设备
3. 选择目标设备（如CH340）
4. 配置波特率等参数
5. 点击"连接设备"

### 2. 终端操作
- **输入命令**: 在底部输入框输入，按Enter发送
- **特殊按键**: 使用底部功能键或物理键盘
- **自定义按键**: 长按自定义按键进行编辑
- **清空终端**: 点击"清空"按钮

### 3. 设置选项
- 字体大小调整
- 字体类型选择
- 自动滚动开关
- 连接状态显示

## 开发环境

### 系统要求
- Flutter SDK 3.9.2+
- Android API 21+
- iOS 11.0+

### 权限配置
应用已配置以下Android权限：
- `USB_PERMISSION` - USB设备访问权限
- `ACCESS_FINE_LOCATION` - 位置权限（USB设备检测需要）
- `ACCESS_COARSE_LOCATION` - 粗略位置权限

### 构建运行
```bash
# 安装依赖
flutter pub get

# 运行应用
flutter run

# 构建APK
flutter build apk --release
```

## 文件结构

```
lib/
├── app/
│   ├── modules/
│   │   └── terminal/
│   │       ├── controllers/
│   │       │   └── terminal_controller.dart
│   │       ├── views/
│   │       │   ├── terminal_view.dart
│   │       │   └── connection_settings_view.dart
│   │       └── bindings/
│   │           └── terminal_binding.dart
│   ├── services/
│   │   └── usb_serial_service.dart
│   └── routes/
│       ├── app_pages.dart
│       └── app_routes.dart
└── main.dart
```

## 注意事项

1. **设备兼容性**: 主要支持CH340、CP2102等常见USB转串口芯片
2. **权限要求**: 首次使用需要授予USB权限
3. **键盘支持**: 支持物理键盘和虚拟键盘输入
4. **数据格式**: 支持文本和二进制数据传输
5. **性能优化**: 终端显示限制1000行，避免内存溢出

## 故障排除

### 设备无法识别
- 检查USB线连接
- 确认设备驱动已安装
- 尝试重新插拔设备
- 检查权限设置

### 连接失败
- 确认波特率设置正确
- 检查数据位、停止位配置
- 尝试其他波特率
- 重启应用

### 数据乱码
- 检查波特率是否匹配
- 确认数据位设置
- 检查校验位配置
- 尝试不同的编码格式

## 更新日志

### v1.0.0
- 初始版本发布
- 支持USB串口连接
- 实现基本终端功能
- 添加自定义按键支持
- 暗色调主题设计

## 许可证

本项目采用MIT许可证，详见LICENSE文件。

## 贡献

欢迎提交Issue和Pull Request来改进这个项目。

---

**开发者**: Flutter + GetX + USB Serial
**版本**: 1.0.0
**更新时间**: 2024年
