# CosmosCalc Flutter — 设置与运行指南

## 第一步：安装 Flutter SDK

```bash
# 推荐使用 brew 安装
brew install --cask flutter

# 或手动安装，参考官方文档：
# https://docs.flutter.dev/get-started/install/macos/desktop
```

安装完成后验证：
```bash
flutter doctor
```

## 第二步：初始化项目（生成平台文件）

进入项目目录，让 Flutter 生成缺少的平台配置文件：

```bash
cd /Users/cuihai/Documents/同步文件/Code/CosmosCalc-Flutter

# 生成 macOS / Windows 桌面支持文件（不会覆盖已有的 lib/ 代码）
flutter create . --platforms=macos,windows

# 安装依赖
flutter pub get
```

## 第三步：在 macOS 本地测试

```bash
# 以 macOS 桌面应用运行（视觉与 Windows 版完全一致）
flutter run -d macos
```

## 第四步：打包 Windows .exe

### 方法 A：GitHub Actions（推荐，无需 Windows 机器）

1. 在 GitHub 创建新仓库并推送：
   ```bash
   git init
   git add .
   git commit -m "Initial CosmosCalc Flutter"
   git remote add origin https://github.com/<你的用户名>/cosmoscalc-flutter.git
   git push -u origin main
   ```

2. GitHub Actions 会自动在 Windows 云机器上编译
3. 进入仓库 → Actions → 最新 workflow → 下载 Artifact **CosmosCalc-Windows-zip**
4. 解压后直接运行 `cosmoscalc.exe`

### 方法 B：本地 Windows 机器

在 Windows 上安装 Flutter 后：
```bash
flutter config --enable-windows-desktop
flutter pub get
flutter build windows --release
# 产物位于：build\windows\x64\runner\Release\
```

---

## 项目结构

```
lib/
├── main.dart                   # 入口，窗口初始化
├── engine/
│   └── calculator_engine.dart  # 计算逻辑（含历史持久化）
├── theme/
│   └── theme.dart              # 颜色/字体/间距常量
├── painters/
│   └── space_background_painter.dart  # 星空背景
├── widgets/
│   ├── metal_button.dart       # 4 种金属风格按钮
│   ├── display_view.dart       # 显示区（含复制/摇晃动画）
│   ├── scientific_panel.dart   # 科学计算面板
│   ├── history_drawer.dart     # 历史记录抽屉
│   └── converter_sheet.dart    # 单位换算面板
└── views/
    └── content_view.dart       # 主布局 + 键盘处理
```

## 功能清单

| 功能 | 快捷键 |
|------|--------|
| 数字输入 | 0-9, . |
| 四则运算 | +, -, *, / |
| 等号 | Enter / = |
| 百分比 | % |
| 清除 | Escape |
| 退格 | Backspace |
| 科学面板 | 点击工具栏"科学" |
| 历史记录 | 点击工具栏"历史" |
| 单位换算 | 点击工具栏"换算" |
| 复制结果 | 点击显示区 |
