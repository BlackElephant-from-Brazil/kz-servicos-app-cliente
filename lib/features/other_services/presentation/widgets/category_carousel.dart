import 'package:flutter/material.dart';
import 'package:kz_servicos_app/core/constants/app_colors.dart';
import 'package:kz_servicos_app/features/other_services/data/models/service_category.dart';
import 'package:kz_servicos_app/features/other_services/presentation/widgets/category_card.dart';

class CategoryCarousel extends StatefulWidget {
  const CategoryCarousel({
    required this.categories,
    required this.onCategorySelected,
    super.key,
  });

  final List<ServiceCategory> categories;
  final ValueChanged<int> onCategorySelected;

  @override
  State<CategoryCarousel> createState() => _CategoryCarouselState();
}

class _CategoryCarouselState extends State<CategoryCarousel> {
  late final PageController _pageController;
  double _currentPage = 0;
  int _activePage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.65);
    _pageController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _pageController.removeListener(_onScroll);
    _pageController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_pageController.page != null) {
      setState(() {
        _currentPage = _pageController.page!;
        _activePage = _currentPage.round();
      });
    }
  }

  void _onCardTap(int index) {
    if (index == _activePage) {
      widget.onCategorySelected(index);
    } else {
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 320,
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.categories.length,
            clipBehavior: Clip.none,
            itemBuilder: (context, index) {
              return _AnimatedCard(
                index: index,
                currentPage: _currentPage,
                category: widget.categories[index],
                isSelected: index == _activePage,
                onTap: () => _onCardTap(index),
              );
            },
          ),
        ),
        const SizedBox(height: 20),
        _CarouselDots(
          count: widget.categories.length,
          currentIndex: _activePage,
        ),
      ],
    );
  }
}

class _AnimatedCard extends StatelessWidget {
  const _AnimatedCard({
    required this.index,
    required this.currentPage,
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  final int index;
  final double currentPage;
  final ServiceCategory category;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final distance = (index - currentPage).abs().clamp(0.0, 1.0);
    final scale = 1.0 - (distance * 0.15);
    final opacity = 1.0 - (distance * 0.3);
    final translateY = distance * 20;

    return Transform.translate(
      offset: Offset(0, translateY),
      child: Transform.scale(
        scale: scale,
        child: Opacity(
          opacity: opacity.clamp(0.0, 1.0),
          child: CategoryCard(
            category: category,
            isSelected: isSelected,
            onTap: onTap,
          ),
        ),
      ),
    );
  }
}

class _CarouselDots extends StatelessWidget {
  const _CarouselDots({
    required this.count,
    required this.currentIndex,
  });

  final int count;
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        final isActive = index == currentIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: isActive ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.highlight
                : AppColors.textPrimary.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}
