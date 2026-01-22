import 'package:flutter/material.dart';
import 'app_colors.dart';

class GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final double height;
  final BorderRadius borderRadius;

  const GradientButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.height = 52,
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
  });

  @override
  Widget build(BuildContext context) {
    final disabled = onPressed == null;

    return Opacity(
      opacity: disabled ? 0.6 : 1,
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: AppColors.kGradient,
            borderRadius: borderRadius,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: borderRadius,
              onTap: onPressed,
              child: Center(
                child: Text(
                  text,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class GradientOutline extends StatelessWidget {
  final Widget child;
  final double strokeWidth;
  final BorderRadius borderRadius;
  final Color? backgroundColor;
  final EdgeInsetsGeometry padding;

  const GradientOutline({
    super.key,
    required this.child,
    this.strokeWidth = 2,
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
    this.backgroundColor,
    this.padding = const EdgeInsets.all(14),
  });

  @override
  Widget build(BuildContext context) {
    final innerBg = backgroundColor ?? Theme.of(context).cardColor;
    final radius = borderRadius.topLeft.x; // assumes uniform radius

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: AppColors.kGradient,
        borderRadius: borderRadius,
      ),
      child: Padding(
        padding: EdgeInsets.all(strokeWidth),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: innerBg,
            borderRadius: BorderRadius.circular((radius - strokeWidth).clamp(0, 999)),
          ),
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}
