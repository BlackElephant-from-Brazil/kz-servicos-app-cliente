import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kz_servicos_app/core/constants/app_colors.dart';
import 'package:kz_servicos_app/features/profile/data/models/mock_user.dart';
import 'package:kz_servicos_app/features/profile/data/models/mock_scheduled_trip.dart';
import 'package:kz_servicos_app/features/profile/data/models/mock_trip_history.dart';
import 'package:kz_servicos_app/features/profile/presentation/widgets/profile_header.dart';
import 'package:kz_servicos_app/features/profile/presentation/widgets/quick_actions_grid.dart';
import 'package:kz_servicos_app/features/profile/presentation/widgets/settings_list.dart';
import 'package:kz_servicos_app/features/trip/presentation/widgets/trip_bottom_nav.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _user = MockUser.sample;
  final _scheduledTrips = MockScheduledTrip.samples;
  final _tripHistory = MockTripHistory.samples;
  final int _selectedNavIndex = 2;

  void _onNavTap(int index) {
    if (index == 0) {
      context.go('/trip');
    } else if (index == 1) {
      // Services not available on this branch
    }
    // index == 2 → already on profile, do nothing
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: MediaQuery.of(context).padding.top + 8),
                ProfileHeader(
                  name: _user.name,
                  email: _user.email,
                  profileCompletion: _user.profileCompletion,
                  hasNotifications: _user.unreadMessages > 0,
                  onBackTap: () => context.go('/trip'),
                ),
                const SizedBox(height: 24),
                QuickActionsGrid(
                  completedTrips: _user.completedTrips,
                  requestedServices: _user.requestedServices,
                  unreadMessages: _user.unreadMessages,
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Configurações',
                        style: TextStyle(
                          fontFamily: 'OutfitBlack',
                          fontSize: 18,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SettingsList(
                        scheduledTrips: _scheduledTrips,
                        tripHistory: _tripHistory,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeInOut,
            bottom: 24,
            left: 20,
            right: 20,
            child: TripBottomNav(
              selectedIndex: _selectedNavIndex,
              onItemSelected: _onNavTap,
            ),
          ),
        ],
      ),
    );
  }
}
