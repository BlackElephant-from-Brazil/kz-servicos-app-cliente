import 'package:flutter/material.dart';

import 'package:kz_servicos_app/core/constants/app_colors.dart';
import 'package:kz_servicos_app/core/theme/app_theme.dart';
import 'package:kz_servicos_app/features/other_services/data/models/mock_provider.dart';
import 'package:kz_servicos_app/features/other_services/presentation/widgets/rating_stars.dart';

class ProviderDetailSheet extends StatelessWidget {
  final MockProvider provider;
  final VoidCallback onProviderSelected;

  const ProviderDetailSheet({
    super.key,
    required this.provider,
    required this.onProviderSelected,
  });

  static Future<void> show(
    BuildContext context, {
    required MockProvider provider,
    required VoidCallback onProviderSelected,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ProviderDetailSheet(
        provider: provider,
        onProviderSelected: onProviderSelected,
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final day = dt.day.toString().padLeft(2, '0');
    final month = dt.month.toString().padLeft(2, '0');
    return '$day/$month/${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      maxChildSize: 0.9,
      initialChildSize: 0.7,
      minChildSize: 0.4,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 24),
                    _buildPersonalInfo(),
                    const SizedBox(height: 20),
                    _buildSpecialties(),
                    const SizedBox(height: 20),
                    _buildAbout(),
                    const SizedBox(height: 20),
                    _buildFeedbacks(),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
              _buildSelectButton(context),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        _buildAvatar(40),
        const SizedBox(height: 12),
        Text(
          provider.name,
          style: TextStyle(
            fontFamily: AppTheme.fontFamilyTitle,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        RatingStars(rating: provider.rating, size: 20, showNumeric: true),
      ],
    );
  }

  Widget _buildAvatar(double radius) {
    if (provider.photoUrl != null) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: NetworkImage(provider.photoUrl!),
      );
    }
    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.secondary.withValues(alpha: 0.15),
      child: Text(
        provider.initials,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: radius * 0.6,
          color: AppColors.secondary,
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: TextStyle(
          fontFamily: AppTheme.fontFamilyTitle,
          fontSize: 16,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildPersonalInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Informações pessoais'),
        _buildInfoRow('RG', provider.rg),
        const SizedBox(height: 6),
        _buildInfoRow('Data de nascimento', _formatDate(provider.birthDate)),
        const SizedBox(height: 6),
        _buildInfoRow('Experiência', '${provider.yearsOfExperience} anos'),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      children: [
        Text('$label: ', style: const TextStyle(fontSize: 14, color: Colors.grey)),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSpecialties() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Especialidades'),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: provider.specialties.map((s) {
            return Chip(
              label: Text(s, style: const TextStyle(fontSize: 12)),
              backgroundColor: AppColors.secondary.withValues(alpha: 0.08),
              side: BorderSide.none,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildAbout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Sobre'),
        Text(
          provider.experienceDescription,
          style: const TextStyle(fontSize: 14, height: 1.5, color: AppColors.textPrimary),
        ),
      ],
    );
  }

  Widget _buildFeedbacks() {
    if (provider.feedbacks.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Avaliações'),
        ...provider.feedbacks.map(_buildFeedbackCard),
      ],
    );
  }

  Widget _buildFeedbackCard(ProviderFeedback feedback) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    feedback.clientName,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                ),
                Text(
                  _formatDate(feedback.date),
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 4),
            RatingStars(rating: feedback.rating, size: 14),
            const SizedBox(height: 6),
            Text(
              feedback.comment,
              style: const TextStyle(fontSize: 13, height: 1.4, color: AppColors.textPrimary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectButton(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.highlight,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
            onPressed: () {
              Navigator.of(context).pop();
              onProviderSelected();
            },
            child: Text(
              'Selecionar prestador',
              style: TextStyle(fontFamily: AppTheme.fontFamilyTitle, fontSize: 16),
            ),
          ),
        ),
      ),
    );
  }
}
