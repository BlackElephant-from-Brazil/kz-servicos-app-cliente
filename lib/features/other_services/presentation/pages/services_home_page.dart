import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kz_servicos_app/core/constants/app_colors.dart';
import 'package:kz_servicos_app/core/theme/app_theme.dart';
import 'package:kz_servicos_app/features/other_services/data/models/service_category.dart';
import 'package:kz_servicos_app/features/other_services/data/models/service_request.dart';
import 'package:kz_servicos_app/features/other_services/presentation/widgets/category_carousel.dart';
import 'package:kz_servicos_app/features/other_services/presentation/widgets/service_request_form.dart';
import 'package:kz_servicos_app/features/trip/presentation/widgets/trip_bottom_nav.dart';

class ServicesHomePage extends StatefulWidget {
  const ServicesHomePage({super.key});

  @override
  State<ServicesHomePage> createState() => _ServicesHomePageState();
}

class _ServicesHomePageState extends State<ServicesHomePage> {
  int? _selectedCategoryIndex;
  final List<ServiceRequest> _requests = [];

  void _onCategorySelected(int index) {
    setState(() {
      _selectedCategoryIndex =
          _selectedCategoryIndex == index ? null : index;
    });
  }

  void _onFormSubmit(ServiceRequest request) {
    _requests.add(request);
    context.go('/services/requests');
  }

  void _onNavItemSelected(int index) {
    switch (index) {
      case 0:
        context.go('/trip');
      case 2:
        // Profile — not yet implemented
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedCategory = _selectedCategoryIndex != null
        ? kServiceCategories[_selectedCategoryIndex!]
        : null;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          _ScrollableContent(
            selectedCategory: selectedCategory,
            onCategorySelected: _onCategorySelected,
            onFormSubmit: _onFormSubmit,
          ),
          Positioned(
            bottom: 24,
            left: 20,
            right: 20,
            child: TripBottomNav(
              selectedIndex: 1,
              onItemSelected: _onNavItemSelected,
            ),
          ),
        ],
      ),
    );
  }
}

class _ScrollableContent extends StatelessWidget {
  const _ScrollableContent({
    required this.selectedCategory,
    required this.onCategorySelected,
    required this.onFormSubmit,
  });

  final ServiceCategory? selectedCategory;
  final ValueChanged<int> onCategorySelected;
  final ValueChanged<ServiceRequest> onFormSubmit;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _GreetingHeader(),
          CategoryCarousel(
            categories: kServiceCategories,
            onCategorySelected: onCategorySelected,
          ),
          const SizedBox(height: 16),
          _FormSection(
            category: selectedCategory,
            onSubmit: onFormSubmit,
          ),
          const SizedBox(height: 120),
        ],
      ),
    );
  }
}

class _GreetingHeader extends StatelessWidget {
  const _GreetingHeader();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
        child: Text(
          'Olá! Qual serviço\nvocê precisa?',
          style: TextStyle(
            fontFamily: AppTheme.fontFamilyTitle,
            fontSize: 22,
            color: AppColors.textPrimary,
            height: 1.3,
          ),
        ),
      ),
    );
  }
}

class _FormSection extends StatelessWidget {
  const _FormSection({
    required this.category,
    required this.onSubmit,
  });

  final ServiceCategory? category;
  final ValueChanged<ServiceRequest> onSubmit;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SizeTransition(
            sizeFactor: animation,
            axisAlignment: -1,
            child: child,
          ),
        );
      },
      child: category == null
          ? const SizedBox.shrink()
          : Padding(
              key: ValueKey(category!.id),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ServiceRequestForm(
                category: category!,
                onSubmit: onSubmit,
              ),
            ),
    );
  }
}
