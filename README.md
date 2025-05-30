# CCD Film Camera 📷

一款专注于复刻90年代CCD数码相机质感的iOS相机应用，让每一张照片都充满怀旧氛围和胶片质感。

![App Icon](./Assets/app-icon.png)

## ✨ 特性

- 🎨 **专业滤镜** - 精心调制的CCD数码相机滤镜和经典胶片效果
- 📸 **实时预览** - 拍摄时即可看到滤镜效果，所见即所得
- 🎯 **简单易用** - 极简的操作界面，专注于拍摄体验
- 💾 **无损保存** - 同时保存原图和滤镜效果图
- 🎮 **手势控制** - 直观的手势操作，快速切换滤镜和调节参数

## 🚀 快速开始

### 环境要求

- macOS 12.0+
- Xcode 14.0+
- iOS 15.0+
- Swift 5.7+

### 安装步骤

1. 克隆项目
```bash
git clone https://github.com/yourusername/ccd-camera.git
cd ccd-camera
```

2. 打开项目
```bash
open ccd.xcodeproj
```

3. 配置开发者账号
   - 在Xcode中选择你的开发团队
   - 修改Bundle Identifier

4. 运行项目
   - 选择目标设备或模拟器
   - 点击运行按钮（⌘R）

## 📱 功能介绍

### 核心滤镜

#### CCD经典系列
- **CCD Classic** - 还原90年代数码相机的经典色彩
- **CCD Warm** - 温暖怀旧的黄调效果
- **CCD Cool** - 清冷的蓝绿色调

#### 胶片系列
- **Fuji 400H** - 日系清新风格
- **Kodak Gold 200** - 经典柯达暖调
- **Agfa Vista** - 欧美复古色彩

### 编辑功能
- 时间戳添加（90年代风格）
- 复古边框
- 颗粒感调节
- 漏光效果

## 🏗 项目结构

```
ccd/
├── ccd/                    # 主应用目录
│   ├── Views/             # SwiftUI视图
│   ├── ViewModels/        # 视图模型
│   ├── Services/          # 业务服务
│   ├── Models/            # 数据模型
│   ├── Filters/           # 滤镜实现
│   └── Resources/         # 资源文件
├── 产品文档.md            # 产品需求文档
├── 技术实现路线图.md       # 技术实现细节
└── README.md              # 本文件
```

## 🛠 技术栈

- **UI框架**: SwiftUI
- **相机**: AVFoundation
- **图像处理**: Core Image + Metal
- **数据存储**: Core Data + FileManager
- **架构模式**: MVVM

## 📸 截图

<table>
  <tr>
    <td><img src="./Screenshots/camera.png" width="200"/></td>
    <td><img src="./Screenshots/filters.png" width="200"/></td>
    <td><img src="./Screenshots/gallery.png" width="200"/></td>
  </tr>
  <tr>
    <td align="center">相机界面</td>
    <td align="center">滤镜选择</td>
    <td align="center">相册浏览</td>
  </tr>
</table>

## 🎯 开发计划

- [x] 项目初始化
- [ ] 基础相机功能
- [ ] 滤镜引擎实现
- [ ] UI界面开发
- [ ] 图片存储管理
- [ ] 性能优化
- [ ] App Store上架

详细的开发计划请查看[技术实现路线图](./技术实现路线图.md)

## 🤝 贡献指南

欢迎提交Issue和Pull Request！

### 开发流程

1. Fork 本仓库
2. 创建你的特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交你的改动 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 开启一个 Pull Request

### 代码规范

- 遵循 [Swift Style Guide](https://github.com/raywenderlich/swift-style-guide)
- 使用 SwiftLint 进行代码检查
- 保持代码简洁和可读性

## 📄 许可证

本项目采用 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情

## 📞 联系方式

- 邮箱: 1196452041@qq.com
- 微信: xrw119
- Issue: [GitHub Issues](https://github.com/xiarongwen/ccd-cam-app)

## 🙏 致谢

感谢所有为这个项目做出贡献的开发者！

---

Made with ❤️ by [Your Name] 