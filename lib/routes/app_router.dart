import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kz_servicos_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:kz_servicos_app/features/auth/presentation/cubit/auth_state.dart';
import 'package:kz_servicos_app/features/auth/presentation/pages/login_page.dart';
import 'package:kz_servicos_app/features/profile/presentation/pages/chat_page.dart';
import 'package:kz_servicos_app/features/profile/presentation/pages/messages_page.dart';
import 'package:kz_servicos_app/features/profile/presentation/pages/profile_page.dart';
import 'package:kz_servicos_app/features/profile/presentation/pages/scheduled_trips_page.dart';
import 'package:kz_servicos_app/features/profile/presentation/pages/security_settings_page.dart';
import 'package:kz_servicos_app/features/profile/presentation/pages/trip_history_page.dart';
import 'package:kz_servicos_app/features/profile/presentation/pages/wallet_page.dart';
import 'package:kz_servicos_app/features/other_services/data/models/service_category.dart';
import 'package:kz_servicos_app/features/other_services/data/models/service_request.dart';
import 'package:kz_servicos_app/features/other_services/presentation/pages/my_requests_page.dart';
import 'package:kz_servicos_app/features/other_services/presentation/pages/request_detail_page.dart';
import 'package:kz_servicos_app/features/other_services/presentation/pages/service_request_form_page.dart';
import 'package:kz_servicos_app/features/other_services/presentation/pages/category_selection_page.dart';
import 'package:kz_servicos_app/features/other_services/presentation/pages/services_home_page.dart';
import 'package:kz_servicos_app/features/splash/presentation/pages/splash_page.dart';
import 'package:kz_servicos_app/features/trip/presentation/pages/trip_home_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:kz_servicos_app/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:kz_servicos_app/features/chat/presentation/cubit/chat_cubit.dart';
import 'package:kz_servicos_app/features/chat/presentation/cubit/messages_cubit.dart';
import 'package:kz_servicos_app/features/trip/data/repositories/trip_repository_impl.dart';
import 'package:kz_servicos_app/features/trip/domain/entities/scheduled_trip.dart';

const _publicRoutes = {'/splash', '/login'};

abstract final class AppRouter {
  static GoRouter createRouter(AuthCubit authCubit) {
    return GoRouter(
      initialLocation: '/splash',
      refreshListenable: _AuthNotifier(authCubit),
      redirect: (context, state) {
        final isLoggedIn = authCubit.state is AuthSuccess;
        final isPublic = _publicRoutes.contains(state.matchedLocation);

        if (!isLoggedIn && !isPublic) return '/login';
        return null;
      },
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
        builder: (context, state) {
          final client = Supabase.instance.client;
          final clientId = client.auth.currentUser!.id;
          return BlocProvider(
            create: (_) => MessagesCubit(
              tripRepository: TripRepositoryImpl(client: client),
              chatRepository: ChatRepositoryImpl(client: client),
              clientId: clientId,
            )..load(),
            child: const MessagesPage(),
          );
        },
      ),
      GoRoute(
        path: '/chat/:tripId',
        builder: (context, state) {
          final client = Supabase.instance.client;
          final tripId = state.pathParameters['tripId']!;
          final trip = state.extra as ScheduledTrip?;
          return BlocProvider(
            create: (_) => ChatCubit(
              chatRepository: ChatRepositoryImpl(client: client),
              currentUserId: client.auth.currentUser!.id,
            )..init(
                tripId,
                tripOrigin: trip?.origin,
                tripDestination: trip?.destination,
              ),
            child: const ChatPage(),
          );
        },
      ),
      GoRoute(
        path: '/wallet',
        builder: (context, state) => const WalletPage(),
      ),
      GoRoute(
        path: '/trip-history',
        builder: (context, state) => const TripHistoryPage(),
      ),
      GoRoute(
        path: '/services',
        builder: (context, state) => const ServicesHomePage(),
      ),
      GoRoute(
        path: '/services/new',
        builder: (context, state) => const CategorySelectionPage(),
      ),
      GoRoute(
        path: '/services/request-form',
        builder: (context, state) {
          final category = state.extra! as ServiceCategory;
          return ServiceRequestFormPage(category: category);
        },
      ),
      GoRoute(
        path: '/services/requests',
        builder: (context, state) => const MyRequestsPage(),
      ),
      GoRoute(
        path: '/services/requests/:id',
        builder: (context, state) {
          final request = state.extra! as ServiceRequest;
          return RequestDetailPage(request: request);
        },
      ),
    ],
    );
  }
}

class _AuthNotifier extends ChangeNotifier {
  _AuthNotifier(AuthCubit cubit) {
    cubit.stream.listen((_) => notifyListeners());
  }
}
