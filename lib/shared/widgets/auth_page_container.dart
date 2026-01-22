import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AuthPageContainer extends StatelessWidget {
  final Widget child;

  const AuthPageContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;

    // Web / desktop: clamp width, Mobile: full width
    final maxWidth = (kIsWeb || w >= 700) ? 520.0 : double.infinity;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Center(
            // ✅ vertical center
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: Theme.of(context).dividerColor.withValues(alpha: 0.18),
                  ),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 22,
                      spreadRadius: 0,
                      offset: const Offset(0, 10),
                      color: Colors.black.withValues(alpha:  
                        Theme.of(context).brightness == Brightness.dark ? 0.35 : 0.10,
                      ),
                    ),
                  ],
                ),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
