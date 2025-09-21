# Flutter Git项目管理客户端 - 项目结构和技术栈

## 项目初始化

### 1. 创建Flutter项目
```bash
flutter create git_project_manager
cd git_project_manager
```

### 2. 启用桌面支持
```bash
flutter config --enable-windows-desktop
flutter config --enable-macos-desktop
flutter config --enable-linux-desktop
```

### 3. 添加依赖包
```yaml
# pubspec.yaml
name: git_project_manager
description: A Git project management desktop client built with Flutter
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'
  flutter: ">=3.10.0"

dependencies:
  flutter:
    sdk: flutter
  
  # 状态管理
  flutter_riverpod: ^2.4.0
  riverpod_annotation: ^2.3.0
  
  # UI组件
  cupertino_icons: ^1.0.2
  material_design_icons_flutter: ^7.0.7296
  
  # Git操作
  git2dart: ^0.0.1
  process_run: ^0.12.5
  
  # 数据存储
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  sqflite: ^2.3.0
  path_provider: ^2.1.0
  
  # 网络请求
  dio: ^5.3.0
  connectivity_plus: ^5.0.0
  
  # 文件操作
  file_picker: ^6.1.0
  path: ^1.8.3
  
  # 工具库
  intl: ^0.18.0
  uuid: ^4.1.0
  equatable: ^2.0.5
  
  # 主题和样式
  flutter_colorpicker: ^1.0.3
  google_fonts: ^6.1.0
  
  # 动画
  lottie: ^2.7.0
  shimmer: ^3.0.0
  
  # 图表
  fl_chart: ^0.65.0
  
  # 代码高亮
  flutter_highlight: ^0.7.0
  highlight: ^0.6.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  
  # 代码生成
  build_runner: ^2.4.0
  riverpod_generator: ^2.3.0
  hive_generator: ^2.0.1
  json_annotation: ^4.8.0
  json_serializable: ^6.7.0
  
  # 测试
  mockito: ^5.4.0
  integration_test:
    sdk: flutter
  
  # 代码质量
  flutter_lints: ^3.0.0
  very_good_analysis: ^5.1.0

flutter:
  uses-material-design: true
  
  # 资源文件
  assets:
    - assets/images/
    - assets/icons/
    - assets/animations/
    - assets/fonts/
  
  # 字体配置
  fonts:
    - family: Roboto
      fonts:
        - asset: assets/fonts/Roboto-Regular.ttf
        - asset: assets/fonts/Roboto-Bold.ttf
          weight: 700
```

## 项目目录结构

```
lib/
├── main.dart                          # 应用入口
├── app/                               # 应用配置
│   ├── app.dart                       # 应用主类
│   ├── routes/                        # 路由配置
│   │   ├── app_router.dart
│   │   └── route_names.dart
│   ├── theme/                         # 主题配置
│   │   ├── app_theme.dart
│   │   ├── app_colors.dart
│   │   └── app_text_styles.dart
│   └── constants/                     # 应用常量
│       ├── app_constants.dart
│       └── api_constants.dart
├── core/                              # 核心功能
│   ├── error/                         # 错误处理
│   │   ├── exceptions.dart
│   │   ├── failures.dart
│   │   └── error_handler.dart
│   ├── network/                       # 网络配置
│   │   ├── network_info.dart
│   │   └── dio_client.dart
│   ├── utils/                         # 工具类
│   │   ├── validators.dart
│   │   ├── formatters.dart
│   │   └── extensions.dart
│   └── services/                      # 核心服务
│       ├── storage_service.dart
│       ├── notification_service.dart
│       └── analytics_service.dart
├── features/                          # 功能模块
│   ├── projects/                      # 项目管理
│   │   ├── data/                      # 数据层
│   │   │   ├── datasources/
│   │   │   │   ├── project_local_datasource.dart
│   │   │   │   └── project_remote_datasource.dart
│   │   │   ├── models/
│   │   │   │   ├── project_model.dart
│   │   │   │   └── project_hive_model.dart
│   │   │   └── repositories/
│   │   │       └── project_repository_impl.dart
│   │   ├── domain/                    # 领域层
│   │   │   ├── entities/
│   │   │   │   └── project.dart
│   │   │   ├── repositories/
│   │   │   │   └── project_repository.dart
│   │   │   └── usecases/
│   │   │       ├── get_projects.dart
│   │   │       ├── add_project.dart
│   │   │       ├── update_project.dart
│   │   │       └── delete_project.dart
│   │   └── presentation/              # 表现层
│   │       ├── pages/
│   │       │   ├── project_list_page.dart
│   │       │   └── project_detail_page.dart
│   │       ├── widgets/
│   │       │   ├── project_card.dart
│   │       │   ├── project_sidebar.dart
│   │       │   └── project_overview_card.dart
│   │       └── providers/
│   │           ├── project_providers.dart
│   │           └── project_notifiers.dart
│   ├── git_operations/                # Git操作
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   └── git_datasource.dart
│   │   │   ├── models/
│   │   │   │   ├── git_status_model.dart
│   │   │   │   ├── git_commit_model.dart
│   │   │   │   └── git_branch_model.dart
│   │   │   └── repositories/
│   │   │       └── git_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   ├── git_status.dart
│   │   │   │   ├── git_commit.dart
│   │   │   │   └── git_branch.dart
│   │   │   ├── repositories/
│   │   │   │   └── git_repository.dart
│   │   │   └── usecases/
│   │   │       ├── get_git_status.dart
│   │   │       ├── commit_changes.dart
│   │   │       ├── push_changes.dart
│   │   │       └── pull_changes.dart
│   │   └── presentation/
│   │       ├── pages/
│   │       │   ├── git_status_page.dart
│   │       │   └── commit_page.dart
│   │       ├── widgets/
│   │       │   ├── git_status_card.dart
│   │       │   ├── file_changes_list.dart
│   │       │   └── commit_form.dart
│   │       └── providers/
│   │           └── git_providers.dart
│   ├── diff_viewer/                   # 差异查看
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   └── diff_datasource.dart
│   │   │   ├── models/
│   │   │   │   └── diff_model.dart
│   │   │   └── repositories/
│   │   │       └── diff_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── diff.dart
│   │   │   ├── repositories/
│   │   │   │   └── diff_repository.dart
│   │   │   └── usecases/
│   │   │       └── get_file_diff.dart
│   │   └── presentation/
│   │       ├── pages/
│   │       │   └── diff_viewer_page.dart
│   │       ├── widgets/
│   │       │   ├── diff_viewer.dart
│   │       │   ├── diff_line.dart
│   │       │   └── diff_controls.dart
│   │       └── providers/
│   │           └── diff_providers.dart
│   ├── commit_history/                # 提交历史
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   └── commit_history_datasource.dart
│   │   │   ├── models/
│   │   │   │   └── commit_history_model.dart
│   │   │   └── repositories/
│   │   │       └── commit_history_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── commit_history.dart
│   │   │   ├── repositories/
│   │   │   │   └── commit_history_repository.dart
│   │   │   └── usecases/
│   │   │       └── get_commit_history.dart
│   │   └── presentation/
│   │       ├── pages/
│   │       │   └── commit_history_page.dart
│   │       ├── widgets/
│   │       │   ├── commit_history_list.dart
│   │       │   ├── commit_item.dart
│   │       │   └── commit_details.dart
│   │       └── providers/
│   │           └── commit_history_providers.dart
│   └── settings/                      # 设置
│       ├── data/
│       │   ├── datasources/
│       │   │   └── settings_datasource.dart
│       │   ├── models/
│       │   │   └── settings_model.dart
│       │   └── repositories/
│       │       └── settings_repository_impl.dart
│       ├── domain/
│       │   ├── entities/
│       │   │   └── settings.dart
│       │   ├── repositories/
│       │   │   └── settings_repository.dart
│       │   └── usecases/
│       │       ├── get_settings.dart
│       │       └── update_settings.dart
│       └── presentation/
│           ├── pages/
│           │   └── settings_page.dart
│           ├── widgets/
│           │   ├── settings_section.dart
│           │   ├── theme_selector.dart
│           │   └── language_selector.dart
│           └── providers/
│               └── settings_providers.dart
├── shared/                            # 共享组件
│   ├── widgets/                       # 通用组件
│   │   ├── common/
│   │   │   ├── loading_widget.dart
│   │   │   ├── error_widget.dart
│   │   │   ├── empty_widget.dart
│   │   │   └── retry_widget.dart
│   │   ├── forms/
│   │   │   ├── custom_text_field.dart
│   │   │   ├── custom_dropdown.dart
│   │   │   └── custom_checkbox.dart
│   │   ├── buttons/
│   │   │   ├── primary_button.dart
│   │   │   ├── secondary_button.dart
│   │   │   └── icon_button.dart
│   │   └── cards/
│   │       ├── info_card.dart
│   │       ├── action_card.dart
│   │       └── status_card.dart
│   ├── services/                      # 共享服务
│   │   ├── git_service.dart
│   │   ├── file_service.dart
│   │   └── notification_service.dart
│   └── models/                        # 共享模型
│       ├── api_response.dart
│       ├── pagination.dart
│       └── base_entity.dart
└── generated/                         # 生成的代码
    ├── *.g.dart
    ├── *.freezed.dart
    └── *.mocks.dart
```

## 核心配置文件

### 1. 应用主类 (app/app.dart)
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import 'theme/app_theme.dart';
import 'routes/app_router.dart';
import 'core/services/storage_service.dart';

class GitProjectManagerApp extends ConsumerWidget {
  const GitProjectManagerApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Git项目管理器',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: ref.watch(appRouterProvider),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(1.0),
          ),
          child: child!,
        );
      },
    );
  }
}

class AppInitializer extends ConsumerStatefulWidget {
  final Widget child;
  
  const AppInitializer({Key? key, required this.child}) : super(key: key);

  @override
  ConsumerState<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends ConsumerState<AppInitializer> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // 初始化Hive
      await Hive.initFlutter();
      
      // 初始化存储服务
      await ref.read(storageServiceProvider).initialize();
      
      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      // 处理初始化错误
      debugPrint('App initialization failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const MaterialApp(
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }
    
    return widget.child;
  }
}
```

### 2. 主题配置 (app/theme/app_theme.dart)
```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
      ),
      textTheme: GoogleFonts.robotoTextTheme(),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.onSurface,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AppTextStyles.headlineSmall.copyWith(
          color: AppColors.onSurface,
        ),
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: AppColors.surface,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.dark,
      ),
      textTheme: GoogleFonts.robotoTextTheme(ThemeData.dark().textTheme),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.darkSurface,
        foregroundColor: AppColors.darkOnSurface,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AppTextStyles.headlineSmall.copyWith(
          color: AppColors.darkOnSurface,
        ),
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: AppColors.darkSurface,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.darkOutline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.darkOutline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}
```

### 3. 颜色配置 (app/theme/app_colors.dart)
```dart
import 'package:flutter/material.dart';

class AppColors {
  // 主色调
  static const Color primary = Color(0xFF1976D2);
  static const Color primaryVariant = Color(0xFF1565C0);
  static const Color secondary = Color(0xFF03DAC6);
  static const Color secondaryVariant = Color(0xFF018786);
  
  // 表面颜色
  static const Color surface = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFF5F5F5);
  static const Color onSurface = Color(0xFF1C1B1F);
  static const Color onBackground = Color(0xFF1C1B1F);
  
  // 状态颜色
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);
  
  // 中性颜色
  static const Color outline = Color(0xFF79747E);
  static const Color outlineVariant = Color(0xFFCAC4D0);
  
  // 深色主题颜色
  static const Color darkSurface = Color(0xFF121212);
  static const Color darkBackground = Color(0xFF000000);
  static const Color darkOnSurface = Color(0xFFE6E1E5);
  static const Color darkOnBackground = Color(0xFFE6E1E5);
  static const Color darkOutline = Color(0xFF938F99);
  static const Color darkOutlineVariant = Color(0xFF49454F);
  
  // Git状态颜色
  static const Color gitModified = Color(0xFFFF9800);
  static const Color gitAdded = Color(0xFF4CAF50);
  static const Color gitDeleted = Color(0xFFF44336);
  static const Color gitRenamed = Color(0xFF2196F3);
  static const Color gitUntracked = Color(0xFF9C27B0);
}
```

### 4. 文本样式配置 (app/theme/app_text_styles.dart)
```dart
import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  // 标题样式
  static const TextStyle displayLarge = TextStyle(
    fontSize: 57,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.25,
    color: AppColors.onSurface,
  );
  
  static const TextStyle displayMedium = TextStyle(
    fontSize: 45,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    color: AppColors.onSurface,
  );
  
  static const TextStyle displaySmall = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    color: AppColors.onSurface,
  );
  
  // 标题样式
  static const TextStyle headlineLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    color: AppColors.onSurface,
  );
  
  static const TextStyle headlineMedium = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    color: AppColors.onSurface,
  );
  
  static const TextStyle headlineSmall = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    color: AppColors.onSurface,
  );
  
  // 标题样式
  static const TextStyle titleLarge = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    color: AppColors.onSurface,
  );
  
  static const TextStyle titleMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.15,
    color: AppColors.onSurface,
  );
  
  static const TextStyle titleSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    color: AppColors.onSurface,
  );
  
  // 正文样式
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
    color: AppColors.onSurface,
  );
  
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
    color: AppColors.onSurface,
  );
  
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    color: AppColors.onSurface,
  );
  
  // 标签样式
  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    color: AppColors.onSurface,
  );
  
  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    color: AppColors.onSurface,
  );
  
  static const TextStyle labelSmall = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    color: AppColors.onSurface,
  );
}
```

### 5. 路由配置 (app/routes/app_router.dart)
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/projects/presentation/pages/project_list_page.dart';
import '../features/projects/presentation/pages/project_detail_page.dart';
import '../features/settings/presentation/pages/settings_page.dart';
import '../features/git_operations/presentation/pages/commit_page.dart';
import '../features/diff_viewer/presentation/pages/diff_viewer_page.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const ProjectListPage(),
      ),
      GoRoute(
        path: '/project/:projectId',
        name: 'project-detail',
        builder: (context, state) {
          final projectId = state.pathParameters['projectId']!;
          return ProjectDetailPage(projectId: projectId);
        },
      ),
      GoRoute(
        path: '/project/:projectId/commit',
        name: 'commit',
        builder: (context, state) {
          final projectId = state.pathParameters['projectId']!;
          return CommitPage(projectId: projectId);
        },
      ),
      GoRoute(
        path: '/project/:projectId/diff/:filePath',
        name: 'diff',
        builder: (context, state) {
          final projectId = state.pathParameters['projectId']!;
          final filePath = state.pathParameters['filePath']!;
          return DiffViewerPage(
            projectId: projectId,
            filePath: filePath,
          );
        },
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsPage(),
      ),
    ],
  );
});
```

## 开发环境配置

### 1. VS Code 配置 (.vscode/settings.json)
```json
{
  "dart.flutterSdkPath": null,
  "dart.sdkPath": null,
  "editor.formatOnSave": true,
  "editor.codeActionsOnSave": {
    "source.fixAll": true,
    "source.organizeImports": true
  },
  "dart.lineLength": 80,
  "dart.insertArgumentPlaceholders": false,
  "dart.previewFlutterUiGuides": true,
  "dart.previewFlutterUiGuidesCustomTracking": true,
  "dart.closingLabels": true,
  "dart.enableSdkFormatter": true,
  "dart.openDevTools": "flutter",
  "files.associations": {
    "*.dart": "dart"
  }
}
```

### 2. 分析配置 (analysis_options.yaml)
```yaml
include: package:very_good_analysis/analysis_options.yaml

analyzer:
  exclude:
    - "**/*.g.dart"
    - "**/*.freezed.dart"
    - "**/*.mocks.dart"
    - "**/generated/**"

linter:
  rules:
    # 自定义规则
    prefer_const_constructors: true
    prefer_const_literals_to_create_immutables: true
    avoid_print: false
    prefer_single_quotes: true
    sort_constructors_first: true
    sort_unnamed_constructors_first: true
```

### 3. Git 配置 (.gitignore)
```gitignore
# Flutter/Dart/Pub related
**/doc/api/
**/ios/Flutter/.last_build_id
.dart_tool/
.flutter-plugins
.flutter-plugins-dependencies
.packages
.pub-cache/
.pub/
/build/

# Web related
lib/generated_plugin_registrant.dart

# Symbolication related
app.*.symbols

# Obfuscation related
app.*.map.json

# Android Studio will place build artifacts here
/android/app/debug
/android/app/profile
/android/app/release

# IntelliJ
.idea/
*.iml
*.ipr
*.iws

# VSCode
.vscode/

# macOS
.DS_Store

# Windows
Thumbs.db
ehthumbs.db
Desktop.ini

# Linux
*~

# Generated files
*.g.dart
*.freezed.dart
*.mocks.dart
```

这个Flutter项目结构提供了：
- 清晰的分层架构
- 完整的依赖管理
- 现代化的主题配置
- 响应式路由系统
- 开发环境优化配置
