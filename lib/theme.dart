import 'package:flutter/material.dart';

// 主题颜色定义
class WorkAppColors {
  // 主品牌色 - 专业蓝
  static const Color primary = Color(0xFF2563EB); // 活力蓝
  static const Color primaryLight = Color(0xFF3B82F6); // 浅蓝
  static const Color primaryDark = Color(0xFF1D4ED8); // 深蓝

  // 辅助色 - 成功绿
  static const Color success = Color(0xFF10B981); // 成功绿
  static const Color successLight = Color(0xFF34D399); // 浅绿
  static const Color successDark = Color(0xFF059669); // 深绿

  // 警告色 - 活力橙
  static const Color warning = Color(0xFFF59E0B); // 警告橙
  static const Color warningLight = Color(0xFFFBBF24); // 浅橙
  static const Color warningDark = Color(0xFFD97706); // 深橙

  // 错误色 - 警示红
  static const Color error = Color(0xFFEF4444); // 错误红
  static const Color errorLight = Color(0xFFF87171); // 浅红
  static const Color errorDark = Color(0xFFDC2626); // 深红

  // 信息色 - 科技紫
  static const Color info = Color(0xFF8B5CF6); // 信息紫
  static const Color infoLight = Color(0xFFA78BFA); // 浅紫
  static const Color infoDark = Color(0xFF7C3AED); // 深紫

  // 中性色系
  static const Color neutral50 = Color(0xFFF8FAFC); // 最浅灰
  static const Color neutral100 = Color(0xFFF1F5F9); // 浅灰
  static const Color neutral200 = Color(0xFFE2E8F0); // 中浅灰
  static const Color neutral300 = Color(0xFFCBD5E1); // 中灰
  static const Color neutral400 = Color(0xFF94A3B8); // 中深灰
  static const Color neutral500 = Color(0xFF64748B); // 深灰
  static const Color neutral600 = Color(0xFF475569); // 更深灰
  static const Color neutral700 = Color(0xFF334155); // 深灰
  static const Color neutral800 = Color(0xFF1E293B); // 最深灰
  static const Color neutral900 = Color(0xFF0F172A); // 近黑

  // 背景色系
  static const Color background = Color(0xFFFAFBFC); // 主背景
  static const Color surface = Color(0xFFFFFFFF); // 卡片背景
  static const Color surfaceVariant = Color(0xFFF8FAFC); // 变体背景

  // 文字色系
  static const Color textPrimary = Color(0xFF0F172A); // 主文字
  static const Color textSecondary = Color(0xFF475569); // 次文字
  static const Color textTertiary = Color(0xFF94A3B8); // 三级文字
  static const Color textDisabled = Color(0xFFCBD5E1); // 禁用文字

  // 边框色系
  static const Color border = Color(0xFFE2E8F0); // 主边框
  static const Color borderLight = Color(0xFFF1F5F9); // 浅边框
  static const Color borderDark = Color(0xFFCBD5E1); // 深边框

  // 阴影色系
  static const Color shadow = Color(0x1A000000); // 主阴影
  static const Color shadowLight = Color(0x0D000000); // 浅阴影
  static const Color shadowDark = Color(0x33000000); // 深阴影
}

class WorkAppGradients {
  // 主渐变
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [WorkAppColors.primary, WorkAppColors.primaryLight],
  );

  // 成功渐变
  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [WorkAppColors.success, WorkAppColors.successLight],
  );

  // 警告渐变
  static const LinearGradient warningGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [WorkAppColors.warning, WorkAppColors.warningLight],
  );

  // 错误渐变
  static const LinearGradient errorGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [WorkAppColors.error, WorkAppColors.errorLight],
  );

  // 信息渐变
  static const LinearGradient infoGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [WorkAppColors.info, WorkAppColors.infoLight],
  );

  // 背景渐变
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [WorkAppColors.background, WorkAppColors.neutral50],
  );

  // 卡片渐变
  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [WorkAppColors.surface, WorkAppColors.surfaceVariant],
  );
}

class WorkAppTheme {
  // 浅色主题
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      // 颜色方案
      colorScheme: const ColorScheme.light(
        primary: WorkAppColors.primary,
        primaryContainer: WorkAppColors.primaryLight,
        secondary: WorkAppColors.success,
        secondaryContainer: WorkAppColors.successLight,
        tertiary: WorkAppColors.info,
        tertiaryContainer: WorkAppColors.infoLight,
        error: WorkAppColors.error,
        errorContainer: WorkAppColors.errorLight,
        surface: WorkAppColors.surface,
        surfaceVariant: WorkAppColors.surfaceVariant,
        background: WorkAppColors.background,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onTertiary: Colors.white,
        onError: Colors.white,
        onSurface: WorkAppColors.textPrimary,
        onBackground: WorkAppColors.textPrimary,
        outline: WorkAppColors.border,
        outlineVariant: WorkAppColors.borderLight,
      ),

      // AppBar主题
      appBarTheme: const AppBarTheme(
        backgroundColor: WorkAppColors.surface,
        foregroundColor: WorkAppColors.textPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: WorkAppColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),

      // 卡片主题
      cardTheme: CardThemeData(
        color: WorkAppColors.surface,
        elevation: 2,
        shadowColor: WorkAppColors.shadow,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),

      // 按钮主题
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: WorkAppColors.primary,
          foregroundColor: Colors.white,
          elevation: 2,
          shadowColor: WorkAppColors.shadow,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),

      // 输入框主题
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: WorkAppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: WorkAppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: WorkAppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: WorkAppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: WorkAppColors.error),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),

      // 文本主题
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: WorkAppColors.textPrimary,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
        displayMedium: TextStyle(
          color: WorkAppColors.textPrimary,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
        displaySmall: TextStyle(
          color: WorkAppColors.textPrimary,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        headlineLarge: TextStyle(
          color: WorkAppColors.textPrimary,
          fontSize: 22,
          fontWeight: FontWeight.w600,
        ),
        headlineMedium: TextStyle(
          color: WorkAppColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        headlineSmall: TextStyle(
          color: WorkAppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: TextStyle(
          color: WorkAppColors.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        titleMedium: TextStyle(
          color: WorkAppColors.textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        titleSmall: TextStyle(
          color: WorkAppColors.textPrimary,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: TextStyle(
          color: WorkAppColors.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.normal,
        ),
        bodyMedium: TextStyle(
          color: WorkAppColors.textSecondary,
          fontSize: 14,
          fontWeight: FontWeight.normal,
        ),
        bodySmall: TextStyle(
          color: WorkAppColors.textTertiary,
          fontSize: 12,
          fontWeight: FontWeight.normal,
        ),
      ),
    );
  }

  // 深色主题
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      colorScheme: const ColorScheme.dark(
        primary: WorkAppColors.primaryLight,
        primaryContainer: WorkAppColors.primary,
        secondary: WorkAppColors.successLight,
        secondaryContainer: WorkAppColors.success,
        tertiary: WorkAppColors.infoLight,
        tertiaryContainer: WorkAppColors.info,
        error: WorkAppColors.errorLight,
        errorContainer: WorkAppColors.error,
        surface: WorkAppColors.neutral800,
        surfaceVariant: WorkAppColors.neutral700,
        background: WorkAppColors.neutral900,
        onPrimary: WorkAppColors.neutral900,
        onSecondary: WorkAppColors.neutral900,
        onTertiary: WorkAppColors.neutral900,
        onError: WorkAppColors.neutral900,
        onSurface: WorkAppColors.neutral100,
        onBackground: WorkAppColors.neutral100,
        outline: WorkAppColors.neutral600,
        outlineVariant: WorkAppColors.neutral700,
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: WorkAppColors.neutral800,
        foregroundColor: WorkAppColors.neutral100,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: WorkAppColors.neutral100,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),

      cardTheme: CardThemeData(
        color: WorkAppColors.neutral800,
        elevation: 2,
        shadowColor: WorkAppColors.shadowDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

class TaskStatusColors {
  // 任务状态颜色
  static const Color pending = WorkAppColors.warning; // 待处理 - 橙色
  static const Color inProgress = WorkAppColors.info; // 进行中 - 紫色
  static const Color completed = WorkAppColors.success; // 已完成 - 绿色
  static const Color cancelled = WorkAppColors.error; // 已取消 - 红色
  static const Color overdue = WorkAppColors.errorDark; // 已逾期 - 深红

  // 优先级颜色
  static const Color high = WorkAppColors.error; // 高优先级 - 红色
  static const Color medium = WorkAppColors.warning; // 中优先级 - 橙色
  static const Color low = WorkAppColors.success; // 低优先级 - 绿色

  // 项目状态颜色
  static const Color planning = WorkAppColors.info; // 规划中 - 紫色
  static const Color active = WorkAppColors.primary; // 进行中 - 蓝色
  static const Color onHold = WorkAppColors.neutral500; // 暂停 - 灰色
  static const Color finished = WorkAppColors.success; // 已完成 - 绿色
}
