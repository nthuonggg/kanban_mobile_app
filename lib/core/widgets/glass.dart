import 'dart:ui';

import 'package:flutter/material.dart';

// Palette "Fluid Luminary" — trích từ mock HTML của user.
class GlassPalette {
  static const Color surface = Color(0xFFF6F6FB);
  static const Color primary = Color(0xFF0058BB);
  static const Color primaryContainer = Color(0xFF6C9FFF);
  static const Color secondary = Color(0xFF4C49C9);
  static const Color tertiary = Color(0xFFB90034);
  static const Color tertiaryFixed = Color(0xFFFF9197);
  static const Color onSurface = Color(0xFF2D2F33);
  static const Color onSurfaceVariant = Color(0xFF5A5B60);
  static const Color outlineVariant = Color(0xFFACADB1);
  static const Color surfaceContainerLow = Color(0xFFF0F0F6);
  static const Color surfaceContainerHigh = Color(0xFFE1E2E8);
}

/// Hộp kính mờ (frosted glass) — dùng cho card / sheet / panel.
class GlassContainer extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double blur;
  final double opacity;
  final bool bordered;
  final VoidCallback? onTap;

  const GlassContainer({
    super.key,
    required this.child,
    this.borderRadius = 20,
    this.padding,
    this.margin,
    this.blur = 20,
    this.opacity = 0.65,
    this.bordered = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = Colors.white.withValues(alpha: 0.7);

    final content = ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: opacity),
            borderRadius: BorderRadius.circular(borderRadius),
            border: bordered ? Border.all(color: borderColor, width: 1) : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );

    return Container(
      margin: margin,
      child: onTap == null
          ? content
          : Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(borderRadius),
                onTap: onTap,
                child: content,
              ),
            ),
    );
  }
}

/// Nền mesh gradient: trắng + 4 blob radial ở 4 góc (từ mock HTML).
class GlassBackground extends StatelessWidget {
  final Widget child;
  const GlassBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: GlassPalette.surface,
      child: Stack(
        children: [
          Positioned(
            top: -120,
            left: -120,
            child: _blob(GlassPalette.primaryContainer, 460, 0.45),
          ),
          Positioned(
            top: -80,
            right: -120,
            child: _blob(GlassPalette.tertiaryFixed, 420, 0.45),
          ),
          Positioned(
            bottom: -140,
            right: -100,
            child: _blob(GlassPalette.secondary, 480, 0.4),
          ),
          Positioned(
            bottom: -120,
            left: -100,
            child: _blob(GlassPalette.primary, 440, 0.3),
          ),
          Positioned.fill(child: child),
        ],
      ),
    );
  }

  Widget _blob(Color color, double size, double alpha) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color.withValues(alpha: alpha),
              color.withValues(alpha: 0),
            ],
          ),
        ),
      ),
    );
  }
}

/// Nút kính mờ — dùng thay ElevatedButton cho style liquid glass.
class GlassButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final double height;
  final bool primary;

  const GlassButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.height = 56,
    this.primary = false,
  });

  @override
  Widget build(BuildContext context) {
    final Widget body;

    if (primary) {
      body = Material(
        color: Colors.transparent,
        child: Ink(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [GlassPalette.primary, GlassPalette.primaryContainer],
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: GlassPalette.primary.withValues(alpha: 0.35),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: onPressed,
            child: Container(
              alignment: Alignment.center,
              child: DefaultTextStyle(
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                child: IconTheme(
                  data: const IconThemeData(color: Colors.white, size: 22),
                  child: child,
                ),
              ),
            ),
          ),
        ),
      );
    } else {
      body = ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Material(
            color: Colors.white.withValues(alpha: 0.65),
            child: InkWell(
              onTap: onPressed,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.8),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: DefaultTextStyle(
                  style: const TextStyle(
                    color: GlassPalette.onSurface,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                  child: IconTheme(
                    data: const IconThemeData(
                      color: GlassPalette.primary,
                      size: 22,
                    ),
                    child: child,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return SizedBox(width: double.infinity, height: height, child: body);
  }
}
