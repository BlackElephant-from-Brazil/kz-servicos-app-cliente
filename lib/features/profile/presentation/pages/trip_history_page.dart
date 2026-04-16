import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kz_servicos_app/core/constants/app_colors.dart';
import 'package:kz_servicos_app/features/profile/data/models/mock_trip_history.dart';
import 'package:kz_servicos_app/features/profile/presentation/widgets/trip_history_card.dart';
import 'package:kz_servicos_app/features/trip/presentation/widgets/trip_bottom_nav.dart';

class TripHistoryPage extends StatefulWidget {
  const TripHistoryPage({super.key});

  @override
  State<TripHistoryPage> createState() => _TripHistoryPageState();
}

class _TripHistoryPageState extends State<TripHistoryPage> {
  String _selectedFilter = 'Todas';
  DateTimeRange? _dateRange;

  static const _filters = ['Todas', 'Este mês', 'Período'];

  List<MockTripHistory> get _filteredTrips {
    final trips = MockTripHistory.samples;
    if (_selectedFilter == 'Este mês') {
      final now = DateTime(2026, 4, 15);
      return trips
          .where(
            (t) =>
                t.completedAt.month == now.month &&
                t.completedAt.year == now.year,
          )
          .toList();
    }
    if (_selectedFilter == 'Período' && _dateRange != null) {
      return trips
          .where(
            (t) =>
                t.completedAt.isAfter(
                  _dateRange!.start.subtract(const Duration(days: 1)),
                ) &&
                t.completedAt.isBefore(
                  _dateRange!.end.add(const Duration(days: 1)),
                ),
          )
          .toList();
    }
    return trips;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Column(
            children: [
              SizedBox(height: MediaQuery.of(context).padding.top + 8),
              _buildHeader(context),
              const SizedBox(height: 16),
              _buildFilters(context),
              const SizedBox(height: 16),
              Expanded(
                child: _filteredTrips.isEmpty
                    ? _buildEmptyState()
                    : _buildTripsList(),
              ),
            ],
          ),
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 12,
            left: 20,
            right: 20,
            child: TripBottomNav(
              selectedIndex: 2,
              onItemSelected: (index) => _onNavTap(context, index),
            ),
          ),
        ],
      ),
    );
  }

  void _onNavTap(BuildContext context, int index) {
    if (index == 0) {
      context.go('/trip');
    } else if (index == 2) {
      context.go('/profile');
    }
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 22,
              color: Color(0xFF999999),
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              'Histórico de Viagens',
              style: TextStyle(
                fontFamily: 'OutfitBlack',
                fontSize: 20,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _filters.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final isSelected = _selectedFilter == filter;
          return GestureDetector(
            onTap: () async {
              if (filter == 'Período') {
                final picked = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime(2025),
                  lastDate: DateTime(2027),
                  initialDateRange: _dateRange,
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: Theme.of(context).colorScheme.copyWith(
                              primary: AppColors.secondary,
                            ),
                      ),
                      child: child!,
                    );
                  },
                );
                if (picked != null) {
                  setState(() {
                    _dateRange = picked;
                    _selectedFilter = filter;
                  });
                }
              } else {
                setState(() => _selectedFilter = filter);
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.secondary : AppColors.white,
                borderRadius: BorderRadius.circular(20),
                border: isSelected
                    ? null
                    : Border.all(color: const Color(0xFFE0E0E0)),
              ),
              alignment: Alignment.center,
              child: Text(
                filter,
                style: TextStyle(
                  fontFamily: 'QuasimodoSemiBold',
                  fontSize: 13,
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.directions_car_outlined,
            size: 48,
            color: Color(0xFFBDBDBD),
          ),
          SizedBox(height: 16),
          Text(
            'Nenhuma viagem encontrada',
            style: TextStyle(
              fontFamily: 'QuasimodoSemiBold',
              fontSize: 16,
              color: Color(0xFF999999),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTripsList() {
    final trips = _filteredTrips;
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
      itemCount: trips.length,
      separatorBuilder: (_, _) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        return TripHistoryCard(trip: trips[index]);
      },
    );
  }
}
