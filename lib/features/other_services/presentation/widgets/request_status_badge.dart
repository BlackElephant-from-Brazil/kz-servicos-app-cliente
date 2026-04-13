import 'package:flutter/material.dart';

import 'package:kz_servicos_app/features/other_services/data/models/service_request.dart';

class RequestStatusBadge extends StatelessWidget {
  final ServiceRequestStatus status;

  const RequestStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final config = _configFor(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: config.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(config.icon, size: 14, color: config.color),
          const SizedBox(width: 4),
          Text(
            config.label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: config.color,
            ),
          ),
        ],
      ),
    );
  }

  static _BadgeConfig _configFor(ServiceRequestStatus status) {
    return switch (status) {
      ServiceRequestStatus.searchingProvider => const _BadgeConfig(
          color: Color(0xFFEF6C00),
          icon: Icons.search,
          label: 'Buscando profissional',
        ),
      ServiceRequestStatus.selectProvider => const _BadgeConfig(
          color: Color(0xFF1565C0),
          icon: Icons.person_search,
          label: 'Selecione o prestador',
        ),
      ServiceRequestStatus.awaitingConfirmation => const _BadgeConfig(
          color: Color(0xFFF9A825),
          icon: Icons.hourglass_top,
          label: 'Aguardando confirmação',
        ),
      ServiceRequestStatus.scheduled => const _BadgeConfig(
          color: Color(0xFF2E7D32),
          icon: Icons.check_circle,
          label: 'Serviço agendado',
        ),
    };
  }
}

class _BadgeConfig {
  final Color color;
  final IconData icon;
  final String label;

  const _BadgeConfig({
    required this.color,
    required this.icon,
    required this.label,
  });
}
