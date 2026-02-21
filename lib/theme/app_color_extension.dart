import 'package:flutter/material.dart';

class AppColorExtension extends ThemeExtension<AppColorExtension> {
  final Color textSecondary;
  final Color buttonPrimary;
  final Color buttonHover;
  final Color border;
  final Color success;
  final Color warning;
  final Color danger;

  const AppColorExtension({
    required this.textSecondary,
    required this.buttonPrimary,
    required this.buttonHover,
    required this.border,
    required this.success,
    required this.warning,
    required this.danger,
  });

  @override
  ThemeExtension<AppColorExtension> copyWith({
    Color? textSecondary,
    Color? buttonPrimary,
    Color? buttonHover,
    Color? border,
    Color? success,
    Color? warning,
    Color? danger,
  }) {
    return AppColorExtension(
      textSecondary: textSecondary ?? this.textSecondary,
      buttonPrimary: buttonPrimary ?? this.buttonPrimary,
      buttonHover: buttonHover ?? this.buttonHover,
      border: border ?? this.border,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      danger: danger ?? this.danger,
    );
  }

  @override
  ThemeExtension<AppColorExtension> lerp(
    covariant ThemeExtension<AppColorExtension>? other,
    double t,
  ) {
    if (other is! AppColorExtension) return this;
    return AppColorExtension(
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      buttonPrimary: Color.lerp(buttonPrimary, other.buttonPrimary, t)!,
      buttonHover: Color.lerp(buttonHover, other.buttonHover, t)!,
      border: Color.lerp(border, other.border, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
    );
  }
}

extension AppColorExtensionX on BuildContext {
  AppColorExtension get colors =>
      Theme.of(this).extension<AppColorExtension>()!;
}
