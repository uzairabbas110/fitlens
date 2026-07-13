import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

import '../../features/authentication/presentation/screens/login_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import 'package:fitlens/features/upload/presentation/screens/upload_screen.dart';

final appRouter = GoRouter(
  redirect: (context, state) {
    final loggedIn = FirebaseAuth.instance.currentUser != null;
    final isLoginPage = state.matchedLocation == '/login';

    if (!loggedIn && !isLoginPage) {
      return '/login';
    }

    if (loggedIn && isLoginPage) {
      return '/home';
    }

    return null;
  },
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/upload',
      builder: (context, state) => const UploadScreen(),
    ),
  ],
);
