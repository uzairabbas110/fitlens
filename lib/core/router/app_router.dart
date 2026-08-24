import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/upload/presentation/screens/upload_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/history/presentation/screens/history_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/profile/presentation/screens/my_colors_screen.dart';
import '../../features/closet/presentation/screens/closet_screen.dart';
import '../../features/sizing/presentation/screens/sizing_screen.dart';
import '../../features/authentication/presentation/providers/auth_provider.dart';
import '../../features/authentication/presentation/screens/login_screen.dart';
import '../../features/authentication/presentation/screens/signup_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/stylist/presentation/screens/stylist_screen.dart';
import '../../features/onboarding/presentation/screens/splash_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/color_analysis/presentation/screens/color_analysis_screen.dart';
import '../../features/profile/presentation/screens/settings_screen.dart';
import '../../features/profile/presentation/screens/premium_screen.dart';
import '../../features/capsule_wardrobe/presentation/screens/capsule_screen.dart';
import '../../features/travel_packing/presentation/screens/travel_packing_screen.dart';
import '../../features/event_stylist/presentation/screens/event_stylist_screen.dart';
import '../../features/profile/presentation/screens/terms_screen.dart';
import '../../features/profile/presentation/screens/privacy_policy_screen.dart';
import '../widgets/app_shell.dart';

abstract final class AppRoutes {
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String home = '/';
  static const String inspiration = '/inspiration';
  static const String history = '/history';
  static const String profile = '/profile';
  static const String upload = '/upload';
  static const String analysis = '/analysis';
  static const String stylist = '/stylist';
  static const String myColors = '/my-colors';
  static const String closet = '/closet';
  static const String sizing = '/sizing';
  static const String colorAnalysis = '/color-analysis';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String settings = '/settings';
  static const String premium = '/premium';
  static const String capsule = '/capsule';
  static const String travelPacking = '/travel-packing';
  static const String eventStylist = '/event-stylist';
  static const String terms = '/terms';
  static const String privacyPolicy = '/privacy-policy';
}

class _RouteErrorScreen extends StatelessWidget {
  final String message;

  const _RouteErrorScreen({
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Navigation Error'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateChangesProvider);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    redirect: (context, state) {
      final isAuthRoute = state.matchedLocation == AppRoutes.login || 
                          state.matchedLocation == AppRoutes.signup;
      final isOnboarding = state.matchedLocation == AppRoutes.splash || 
                           state.matchedLocation == AppRoutes.onboarding;
                          
      if (authState.isLoading) {
        return null;
      }

      final isLoggedIn = authState.value != null;

      if (!isLoggedIn && !isAuthRoute && !isOnboarding) {
        return AppRoutes.login;
      }

      if (isLoggedIn && (isAuthRoute || isOnboarding)) {
        return AppRoutes.home;
      }

      return null;
    },
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.history,
                builder: (context, state) => const HistoryScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.closet,
                builder: (context, state) => const ClosetScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.profile,
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.sizing,
        builder: (context, state) => const SizingScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            key: state.pageKey,
            child: const LoginScreen(),
            transitionDuration: const Duration(milliseconds: 2000),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return AnimatedBuilder(
                animation: animation,
                builder: (context, child) {
                  final curve = CurvedAnimation(parent: animation, curve: Curves.easeInOut);
                  final angle = (1.0 - curve.value) * 3.14159 / 2; // pi/2 to 0
                  return Transform(
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.001) // Perspective
                      ..rotateY(-angle),
                    alignment: Alignment.center,
                    child: Opacity(
                      opacity: curve.value.clamp(0.0, 1.0),
                      child: child,
                    ),
                  );
                },
                child: child,
              );
            },
          );
        },
      ),
      GoRoute(
        path: AppRoutes.signup,
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            key: state.pageKey,
            child: const SignupScreen(),
            transitionDuration: const Duration(milliseconds: 1500),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return AnimatedBuilder(
                animation: animation,
                builder: (context, child) {
                  final curve = CurvedAnimation(parent: animation, curve: Curves.easeInOut);
                  final angle = (1.0 - curve.value) * 3.14159 / 2; // pi/2 to 0
                  return Transform(
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.001) // Perspective
                      ..rotateY(angle), // Rotates from positive pi/2 (reverse flip)
                    alignment: Alignment.center,
                    child: Opacity(
                      opacity: curve.value.clamp(0.0, 1.0),
                      child: child,
                    ),
                  );
                },
                child: child,
              );
            },
          );
        },
      ),
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.stylist,
        builder: (context, state) => const StylistScreen(),
      ),
      GoRoute(
        path: AppRoutes.myColors,
        builder: (context, state) => const MyColorsScreen(),
      ),
      GoRoute(
        path: AppRoutes.settings,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.premium,
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            key: state.pageKey,
            child: const PremiumScreen(),
            transitionDuration: const Duration(milliseconds: 600),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              final curve = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.1),
                  end: Offset.zero,
                ).animate(curve),
                child: FadeTransition(opacity: curve, child: child),
              );
            },
          );
        },
      ),

      GoRoute(
        path: AppRoutes.colorAnalysis,
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            key: state.pageKey,
            child: const ColorAnalysisScreen(),
            transitionDuration: const Duration(milliseconds: 500),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          );
        },
      ),
      GoRoute(
        path: AppRoutes.capsule,
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            key: state.pageKey,
            child: const CapsuleScreen(),
            transitionDuration: const Duration(milliseconds: 500),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              final curve = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.1),
                  end: Offset.zero,
                ).animate(curve),
                child: FadeTransition(opacity: curve, child: child),
              );
            },
          );
        },
      ),
      GoRoute(
        path: AppRoutes.travelPacking,
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            key: state.pageKey,
            child: const TravelPackingScreen(),
            transitionDuration: const Duration(milliseconds: 500),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              final curve = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.1),
                  end: Offset.zero,
                ).animate(curve),
                child: FadeTransition(opacity: curve, child: child),
              );
            },
          );
        },
      ),
      GoRoute(
        path: AppRoutes.eventStylist,
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            key: state.pageKey,
            child: const EventStylistScreen(),
            transitionDuration: const Duration(milliseconds: 500),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              final curve = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.1),
                  end: Offset.zero,
                ).animate(curve),
                child: FadeTransition(opacity: curve, child: child),
              );
            },
          );
        },
      ),
      GoRoute(
        path: AppRoutes.terms,
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const TermsScreen(),
          transitionDuration: const Duration(milliseconds: 400),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curve = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
            return SlideTransition(
              position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero).animate(curve),
              child: child,
            );
          },
        ),
      ),
      GoRoute(
        path: AppRoutes.privacyPolicy,
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const PrivacyPolicyScreen(),
          transitionDuration: const Duration(milliseconds: 400),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curve = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
            return SlideTransition(
              position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero).animate(curve),
              child: child,
            );
          },
        ),
      ),
      GoRoute(
        path: '/upload/:feature',
        pageBuilder: (context, state) {
          final feature = state.pathParameters['feature'] ?? 'all';
          return CustomTransitionPage(
            key: state.pageKey,
            child: UploadScreen(feature: feature),
            transitionDuration: const Duration(milliseconds: 800),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return AnimatedBuilder(
                animation: animation,
                builder: (context, child) {
                  final curve = CurvedAnimation(parent: animation, curve: Curves.easeOutBack);
                  final scaleVal = 0.8 + (0.2 * curve.value);
                  return Transform(
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.001) // Perspective
                      ..scaleByDouble(scaleVal, scaleVal, 1.0, 1.0) // Scale from 0.8 to 1.0
                      ..rotateZ((1.0 - curve.value) * 0.1), // Slight rotation
                    alignment: Alignment.center,
                    child: Opacity(
                      opacity: curve.value.clamp(0.0, 1.0),
                      child: child,
                    ),
                  );
                },
                child: child,
              );
            },
          );
        },
      ),
      GoRoute(
        path: AppRoutes.analysis,
        pageBuilder: (context, state) {
          final extra = state.extra;
          
          if (extra is! Map<String, dynamic>) {
             return const NoTransitionPage(
               child: _RouteErrorScreen(
                 message: 'No valid image data was provided for analysis.',
               ),
             );
          }

          final userImageBytes = extra['userImage'] as Uint8List?;
          final clothingImageBytes = extra['clothingImage'] as Uint8List?;

          if (userImageBytes == null && clothingImageBytes == null) {
            return const NoTransitionPage(
              child: _RouteErrorScreen(
                message: 'Missing image data.',
              ),
            );
          }

          final feature = extra['feature'] as String? ?? 'all';

          return CustomTransitionPage(
            key: state.pageKey,
            child: DashboardScreen(
              userImageBytes: userImageBytes,
              clothingImageBytes: clothingImageBytes,
              feature: feature,
            ),
            transitionDuration: const Duration(milliseconds: 1000),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return AnimatedBuilder(
                animation: animation,
                builder: (context, child) {
                  final curve = CurvedAnimation(parent: animation, curve: Curves.easeOutQuart);
                  // 3D slide up fold: rotates on X axis while sliding up
                  final angle = (1.0 - curve.value) * 3.14159 / 4; // pi/4 to 0 (flips up)
                  final offset = (1.0 - curve.value) * 200; // slides up from 200
                  return Transform(
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.001)
                      ..translateByDouble(0.0, offset, 0.0, 1.0)
                      ..rotateX(-angle),
                    alignment: Alignment.bottomCenter,
                    child: Opacity(
                      opacity: curve.value.clamp(0.0, 1.0),
                      child: child,
                    ),
                  );
                },
                child: child,
              );
            },
          );
        },
      ),
    ],
  );
});