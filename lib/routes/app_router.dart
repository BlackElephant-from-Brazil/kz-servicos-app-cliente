import 'package:go_router/go_router.dart';
import 'package:kz_servicos_app/features/auth/presentation/pages/login_page.dart';
import 'package:kz_servicos_app/features/profile/presentation/pages/chat_page.dart';
import 'package:kz_servicos_app/features/profile/presentation/pages/messages_page.dart';
import 'package:kz_servicos_app/features/profile/presentation/pages/profile_page.dart';
import 'package:kz_servicos_app/features/profile/presentation/pages/scheduled_trips_page.dart';
import 'package:kz_servicos_app/features/profile/presentation/pages/security_settings_page.dart';
import 'package:kz_servicos_app/features/profile/presentation/pages/trip_history_page.dart';
import 'package:kz_servicos_app/features/profile/presentation/pages/wallet_page.dart';
import 'package:kz_servicos_app/features/other_services/presentation/pages/my_requests_page.dart';
import 'package:kz_servicos_app/features/other_services/presentation/pages/request_detail_page.dart';
import 'package:kz_servicos_app/features/other_services/presentation/pages/services_home_page.dart';
import 'package:kz_servicos_app/features/splash/presentation/pages/splash_page.dart';
import 'package:kz_servicos_app/features/trip/presentation/pages/trip_home_page.dart';

abstract final class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/trip',
        builder: (context, state) => const TripHomePage(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfilePage(),
      ),
      GoRoute(
        path: '/scheduled-trips',
        builder: (context, state) => const ScheduledTripsPage(),
      ),
      GoRoute(
        path: '/security-settings',
        builder: (context, state) => const SecuritySettingsPage(),
      ),
      GoRoute(
        path: '/messages',
        builder: (context, state) => const MessagesPage(),
      ),
      GoRoute(
        path: '/chat/:conversationId',
        builder: (context, state) => ChatPage(
          conversationId: state.pathParameters['conversationId']!,
        ),
      ),
      GoRoute(
        path: '/wallet',
        builder: (context, state) => const WalletPage(),
      ),
      GoRoute(
        path: '/trip-history',
        builder: (context, state) => const TripHistoryPage(),
      ),
        path: '/services',
        builder: (context, state) => const ServicesHomePage(),
      ),
      GoRoute(
        path: '/services/requests',
        builder: (context, state) => const MyRequestsPage(),
      ),
      GoRoute(
        path: '/services/requests/:id',
        builder: (context, state) => RequestDetailPage(
          requestId: state.pathParameters['id']!,
        ),
      ),
    ],
  );
}
