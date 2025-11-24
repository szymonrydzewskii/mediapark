// lib/helpers/slide_fade_route.dart
import 'package:flutter/material.dart';

PageRouteBuilder<T> slideFadeRouteTo<T>(Widget page) {
  return PageRouteBuilder<T>(
    transitionDuration: const Duration(milliseconds: 400),
    reverseTransitionDuration: const Duration(milliseconds: 150),
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final slide = Tween<Offset>(
        begin: const Offset(1.0, 0.0),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut));

      final fade = Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeIn));

      return SlideTransition(
        position: slide,
        child: AnimatedBuilder(
          animation: animation,
          builder:
              (context, child) => Opacity(
                opacity:
                    animation.status == AnimationStatus.reverse
                        ? 1.0
                        : fade.value,
                child: child,
              ),
          child: child,
        ),
      );
    },
  );
}
