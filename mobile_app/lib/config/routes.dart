import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../screens/login_screen.dart';
import '../screens/dashboard_screen.dart';
import '../screens/store_list_screen.dart';
import '../screens/order_entry_screen.dart';

class AppRouter {
  late final GoRouter router;

  AppRouter(AuthProvider authProvider) {
    router = GoRouter(
      refreshListenable: authProvider,
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/',
          builder: (context, state) => const DashboardScreen(),
        ),
        GoRoute(
           path: '/stores',
           builder: (context, state) => const StoreListScreen(),
        ),
        GoRoute(
           path: '/order/:storeId',
           builder: (context, state) {
             final storeId = int.parse(state.params['storeId']!);
             return OrderEntryScreen(storeId: storeId);
           },
        ),
        GoRoute(
           path: '/orders',
           builder: (context, state) => const Scaffold(body: Center(child: Text('Order History Placeholder'))),
        ),
      ],
      redirect: (context, state) {
        final loggedIn = authProvider.isAuthenticated;
        final loggingIn = state.location == '/login';
        
        if (!loggedIn && !loggingIn) return '/login';
        if (loggedIn && loggingIn) return '/';
        
        return null;
      },
    );
  }
}
