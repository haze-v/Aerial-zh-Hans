# Aerial 简体中文版

适用于 macOS 的动态墙纸与屏幕保护程序，支持解锁后继续播放、多显示器控制和简体中文界面。

[下载最新版本](https://github.com/x-xxxx/Aerial-zh-Hans/releases/latest) · [反馈问题](https://github.com/x-xxxx/Aerial-zh-Hans/issues)

## 系统要求

- macOS 26 或更新版本。
- 发布的 DMG 适用于 Apple Silicon（M 系列芯片）。

## 安装与更新

1. 从最新版本页面下载 DMG。
2. 打开 DMG，将 Aerial 拖入「应用程序」。
3. 启动 Aerial，在系统设置中选择 Aerial 墙纸或屏幕保护程序。

安装后可在「设置 → 自动更新」检查更新，更新来源为本仓库。

## 主要功能

- **简体中文界面**：菜单栏、视频资料库、墙纸选择、设置、首次启动向导和叠加编辑器。
- **多屏播放**：支持独立播放、镜像及独立播放镜像。独立播放镜像使用相同视频，各屏幕独立暂停；同时满足播放条件时同步进度。
- **随机跳转**：点击骰子或右击状态栏 Aerial 图标随机选片，左击图标打开面板。独立播放时，各屏幕分别抽取并保存历史；镜像模式共用随机结果。
- **可配置防重复**：在「设置 → 高级 → 播放」调整骰子防重复范围，默认 75%，支持 0%–100%。按可选视频数量向下取整，例如 46 个视频默认排除最近 34 个随机结果。0% 关闭历史排除，100% 最多排除总数减一；修改后下次点骰子生效。
- **自动暂停**：支持按窗口遮挡、电池、温度和 CPU 使用率暂停。CPU 规则可设置阈值、采样间隔与持续超阈值时间；连续两次采样低于阈值且没有其他暂停条件时恢复。
- **手动控制**：暂停所有墙纸、调节播放速度、切换收藏或播放列表。手动换片在墙纸被遮挡时也会更新。
- **文件定位**：在视频右键菜单选择打开文件位置，在访达中定位本地视频。

## 常见问题

**墙纸暂停不动**

先查看菜单栏面板底部的暂停原因。窗口遮挡、CPU 占用、电池等规则均可能触发暂停，可在设置中调整。

**出现黑屏或纯色**

可在「设置 → 墙纸 → 故障排除」点击「重新启动墙纸服务」。程序包含解码阻塞恢复及静态画面兜底；不同机器的开机恢复效果可能不同。

## 从源码构建

需要安装 Xcode 和适用于目标系统的 macOS SDK。

```bash
git clone https://github.com/x-xxxx/Aerial-zh-Hans.git
cd Aerial-zh-Hans
open Aerial.xcodeproj
```

在 Xcode 中选择 `Aerial` 构建方案并运行，或使用命令行：

```bash
xcodebuild -project Aerial.xcodeproj -scheme Aerial -configuration Release \
  -derivedDataPath DerivedData ARCHS=arm64 \
  CODE_SIGN_IDENTITY=- CODE_SIGN_STYLE=Manual DEVELOPMENT_TEAM= build
```

构建产物位于 `DerivedData/Build/Products/Release/Aerial.app`。

## 许可证

采用 MIT 许可证，详见 [LICENSE](LICENSE)。
