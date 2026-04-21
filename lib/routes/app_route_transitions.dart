import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Shared durations for route transitions (full-screen pushes).
const Duration _kModalForwardDuration = Duration(milliseconds: 340);
const Duration _kModalReverseDuration = Duration(milliseconds: 280);
const Duration _kFadeForwardDuration = Duration(milliseconds: 420);

/// Central place for GoRouter [CustomTransitionPage] presets.
abstract final class AppRouteTransitions {
  /// Subtle zoom + fade (feels like a sheet/modal opening, reads smoother than a hard slide).
  static CustomTransitionPage<void> modal(GoRouterState state, Widget child) {
    return CustomTransitionPage<void>(
      key: state.pageKey,
      name: state.name,
      child: child,
      transitionDuration: _kModalForwardDuration,
      reverseTransitionDuration: _kModalReverseDuration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.94, end: 1.0).animate(curved),
            alignment: Alignment.center,
            child: child,
          ),
        );
      },
    );
  }

  /// Simple fade (e.g. splash or cross-fade between root destinations).
  static CustomTransitionPage<void> fade(GoRouterState state, Widget child) {
    return CustomTransitionPage<void>(
      key: state.pageKey,
      name: state.name,
      child: child,
      transitionDuration: _kFadeForwardDuration,
      reverseTransitionDuration: _kModalReverseDuration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        return FadeTransition(opacity: curved, child: child);
      },
    );
  }
}
