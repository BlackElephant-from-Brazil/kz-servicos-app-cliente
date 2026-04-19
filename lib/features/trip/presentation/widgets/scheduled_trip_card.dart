import 'package:flutter/material.dart';
import 'package:kz_servicos_app/core/constants/app_colors.dart';
import 'package:kz_servicos_app/features/trip/domain/entities/scheduled_trip.dart';

class ScheduledTripCard extends StatelessWidget {
  const ScheduledTripCard({
    super.key,
    required this.trip,
    this.onTap,
  });

  final ScheduledTrip trip;
  final VoidCallback? onTap;

  static const _monthAbbr = [
    'jan', 'fev', 'mar', 'abr', 'mai', 'jun',
    'jul', 'ago', 'set', 'out', 'nov', 'dez',
  ];

  String get _formattedDate {
    final d = trip.scheduledDatetime;
    final day = d.day;
    final month = _monthAbbr[d.month - 1];
    final hour = d.hour.toString().padLeft(2, '0');
    final minute = d.minute.toString().padLeft(2, '0');
    return '$day $month • $hour:$minute';
  }

  (Color bg, Color text, String label) get _statusInfo {
    return switch (trip.status) {
      'scheduled' => (
        const Color(0xFFE8F5E9),
        const Color(0xFF4CAF50),
        'Agendada',
      ),
      'open' || 'under_review' => (
        const Color(0xFFFFF3E0),
        const Color(0xFFFF9800),
        'Pendente',
      ),
      _ => (
        const Color(0xFFE3F2FD),
        const Color(0xFF2261FE),
        'Em andamento',
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final (bgColor, textColor, label) = _statusInfo;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 220,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.10),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    label,
                    style: TextStyle(
                      fontFamily: 'QuasimodoSemiBold',
                      fontSize: 10,
                      color: textColor,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  _formattedDate,
                  style: TextStyle(
                    fontFamily: 'QuasimodoSemiBold',
                    fontSize: 10,
                    color: AppColors.textPrimary.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: AppColors.secondary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    trip.origin,
                    style: const TextStyle(
                      fontFamily: 'QuasimodoSemiBold',
                      fontSize: 11,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: AppColors.highlight,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    trip.destination,
                    style: const TextStyle(
                      fontFamily: 'QuasimodoSemiBold',
                      fontSize: 11,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
