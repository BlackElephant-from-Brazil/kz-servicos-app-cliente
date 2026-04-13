import 'package:flutter/material.dart';

import 'package:kz_servicos_app/core/constants/app_colors.dart';
import 'package:kz_servicos_app/features/other_services/data/models/mock_provider.dart';
import 'package:kz_servicos_app/features/other_services/presentation/widgets/rating_stars.dart';

class ProviderListTile extends StatelessWidget {
  final MockProvider provider;
  final VoidCallback onTap;

  const ProviderListTile({
    super.key,
    required this.provider,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0D000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            _buildAvatar(),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    provider.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  RatingStars(
                    rating: provider.rating,
                    size: 16,
                    showNumeric: true,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${provider.yearsOfExperience} anos de experiência',
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                  const SizedBox(height: 6),
                  _buildSpecialtiesChips(),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    if (provider.photoUrl != null) {
      return CircleAvatar(
        radius: 28,
        backgroundImage: NetworkImage(provider.photoUrl!),
      );
    }
    return CircleAvatar(
      radius: 28,
      backgroundColor: AppColors.secondary.withValues(alpha: 0.15),
      child: Text(
        provider.initials,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
          color: AppColors.secondary,
        ),
      ),
    );
  }

  Widget _buildSpecialtiesChips() {
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: provider.specialties.map((specialty) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: AppColors.secondary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            specialty,
            style: const TextStyle(fontSize: 11, color: AppColors.secondary),
          ),
        );
      }).toList(),
    );
  }
}
