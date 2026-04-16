import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
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
  final ImagePicker _imagePicker = ImagePicker();
  String? _avatarPath;

  void _onNavTap(int index) {
    if (index == 0) {
      context.go('/trip');
    } else if (index == 1) {
      // Services not available on this branch
    }
    // index == 2 → already on profile, do nothing
  }

  Future<void> _onEditPhoto() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE0E0E0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Alterar Foto',
              style: TextStyle(
                fontFamily: 'OutfitBlack',
                fontSize: 18,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.camera_alt_rounded,
                  color: AppColors.secondary,
                ),
              ),
              title: const Text(
                'Câmera',
                style: TextStyle(
                  fontFamily: 'QuasimodoSemiBold',
                  fontSize: 15,
                  color: AppColors.textPrimary,
                ),
              ),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.highlight.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.photo_library_rounded,
                  color: AppColors.highlight,
                ),
              ),
              title: const Text(
                'Galeria',
                style: TextStyle(
                  fontFamily: 'QuasimodoSemiBold',
                  fontSize: 15,
                  color: AppColors.textPrimary,
                ),
              ),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
            SizedBox(height: MediaQuery.of(ctx).padding.bottom + 8),
          ],
        ),
      ),
    );

    if (source == null) return;

    final picked = await _imagePicker.pickImage(
      source: source,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 80,
    );

    if (picked != null && mounted) {
      setState(() => _avatarPath = picked.path);
    }
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
                  onEditPhotoTap: _onEditPhoto,
                  avatarPath: _avatarPath,
                ),
                const SizedBox(height: 24),
                QuickActionsGrid(
                  completedTrips: _user.completedTrips,
                  requestedServices: _user.requestedServices,
                  unreadMessages: _user.unreadMessages,
                  onTripsTap: () => context.push('/trip-history'),
                  onMessagesTap: () => context.push('/messages'),
                  onPaymentsTap: () => context.push('/wallet'),
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
                        onSecurityTap: () =>
                            context.push('/security-settings'),
                        onViewAllScheduledTap: () =>
                            context.push('/scheduled-trips'),
                        onHistoryTripTap: () =>
                            context.push('/trip-history'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 12,
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
