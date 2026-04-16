import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:kz_servicos_app/core/constants/app_colors.dart';
import 'package:kz_servicos_app/core/theme/app_theme.dart';
import 'package:kz_servicos_app/features/other_services/data/models/service_request.dart';
import 'package:kz_servicos_app/features/other_services/presentation/widgets/request_list_tile.dart';
import 'package:kz_servicos_app/features/trip/presentation/widgets/trip_bottom_nav.dart';

class MyRequestsPage extends StatelessWidget {
  const MyRequestsPage({super.key});

  void _onNavItemSelected(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/trip');
      case 1:
        context.go('/services');
      case 2:
        // Profile — not yet implemented
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final requests = ServiceRequest.mockRequests;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Meus Pedidos',
          style: TextStyle(
            fontFamily: AppTheme.fontFamilyTitle,
            fontSize: 20,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          requests.isEmpty
              ? const _EmptyState()
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 160),
                  itemCount: requests.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final request = requests[index];
                    return RequestListTile(
                      request: request,
                      onTap: () =>
                          context.go('/services/requests/${request.id}'),
                    );
                  },
                ),
          Positioned(
            bottom: 140,
            right: 20,
            child: FloatingActionButton(
              backgroundColor: AppColors.highlight,
              onPressed: () => context.go('/services'),
              child: const Icon(Icons.add, color: Colors.white),
            ),
          ),
          Positioned(
            bottom: 24,
            left: 20,
            right: 20,
            child: TripBottomNav(
              selectedIndex: 1,
              onItemSelected: (i) => _onNavItemSelected(context, i),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 64,
            color: AppColors.textPrimary.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 12),
          Text(
            'Nenhum pedido realizado',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textPrimary.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}
