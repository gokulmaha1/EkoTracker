import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../screens/order_history_screen.dart';
import '../screens/login_screen.dart';
import '../screens/dashboard_screen.dart';
import '../screens/store_list_screen.dart';
import '../screens/order_entry_screen.dart';
import '../screens/add_store_screen.dart';
import '../screens/timeline_screen.dart';
import '../screens/create_post_screen.dart';
import '../screens/store_detail_screen.dart';

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
          path: '/add-store',
          builder: (context, state) => const AddStoreScreen(),
        ),
        GoRoute(
           path: '/stores',
           builder: (context, state) => const StoreListScreen(),
        ),
        GoRoute(
           path: '/store/:id',
           builder: (context, state) {
             final id = int.parse(state.pathParameters['id']!);
             return StoreDetailScreen(storeId: id);
           },
        ),
        GoRoute(
           path: '/order/:storeId',
           builder: (context, state) {
             final storeId = int.parse(state.pathParameters['storeId']!);
             return OrderEntryScreen(storeId: storeId);
           },
        ),
        GoRoute(
           path: '/orders',
           builder: (context, state) => const OrderHistoryScreen(),
        ),
        GoRoute(
           path: '/timeline',
           builder: (context, state) => const TimelineScreen(),
        ),
        GoRoute(
           path: '/create-post',
           builder: (context, state) {
              final storeId = state.uri.queryParameters['storeId'];
              return CreatePostScreen(storeId: storeId != null ? int.parse(storeId) : null);
           },
        ),
      ],
      redirect: (context, state) {
        final loggedIn = authProvider.isAuthenticated;
        final loggingIn = state.uri.toString() == '/login';
        
        if (!loggedIn && !loggingIn) return '/login';
        if (loggedIn && loggingIn) return '/';
        
        return null;
      },
    );
  }
}
