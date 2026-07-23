# Floatick

Floatick 是一个 Flutter + AppKit 实现的 macOS 悬浮待办应用。折叠时显示为
可拖动的大图标，点击后由原生窗口平滑展开为完整待办列表。

> 当前仅支持 macOS，数据完全保存在本机，无账号、无云端依赖。

## 温馨提示

Floatick 目前仍处于早期版本。第一次打开时，如果 macOS 需要额外确认，
按照下面几步操作即可：

1. 先尝试打开一次 Floatick。
2. 打开“系统设置”→“隐私与安全”。
3. 在“安全性”区域找到 Floatick，点击“仍要打开”。
4. 再次确认“打开”，并按提示输入 Mac 登录密码。

完成一次确认后，后续就可以正常启动。建议从本仓库的
[Releases](https://github.com/lucaslushuo/floatick/releases) 页面下载。
具体界面可能随 macOS 版本略有不同，详情参见
[Apple 官方说明](https://support.apple.com/guide/mac-help/open-a-mac-app-from-an-unknown-developer-mh40616/mac)。

## 功能

- 随时新建、勾选和归档待办
- 按年月日自动分组
- 搜索当前待办或归档内容
- 从归档恢复待办
- 设置中支持跟随系统、浅色和深色主题
- 界面跟随 macOS 语言，当前支持简体中文和英文
- 支持 macOS“减少动态效果”
- `⌘F` 搜索、`⌘N` 新建、`Esc` 收起
- 待办仅保存在 `~/.floatick/todos.json`
- 设置仅保存在 `~/.floatick/settings.json`

## 架构

- `lib/app`：应用装配与主题
- `lib/features`：按 todo、settings 功能划分的 data/domain/presentation
- `lib/core`：原生窗口桥接和跨功能 UI 基元
- `macos/Runner`：透明无边框窗口、拖动、位置持久化、焦点和窗口动画
- MethodChannel：只传递窗口命令，不承载待办业务状态

本地 JSON 数据统一保存在 `~/.floatick`，应用不会读取或写入其他隐藏目录。
详细依赖边界见 [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md)。

## 开发

需要 Flutter 3.44 或更高版本，以及完整安装并完成首次配置的 Xcode。

```bash
flutter pub get
flutter run -d macos
```

如果 `flutter doctor -v` 提示 Xcode 未完成安装，请先安装完整 Xcode，然后执行：

```bash
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -runFirstLaunch
```

## 测试

```bash
flutter test
```

## 构建

```bash
flutter build macos --release
```

构建产物位于 `build/macos/Build/Products/Release/Floatick.app`。推送与
`pubspec.yaml` 版本匹配的标签后，GitHub Actions 会构建 universal DMG，
生成 SHA-256 校验文件并发布到 GitHub Releases。

当前版本首次打开时可能需要按照本文顶部的说明完成一次确认。未来完成
Apple Developer 签名后，用户即可直接打开。发布流程见
[docs/RELEASING.md](docs/RELEASING.md)。

## License

[MIT](LICENSE) © 2026 lucaslushuo
