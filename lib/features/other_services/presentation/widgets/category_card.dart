import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:kz_servicos_app/features/other_services/data/models/service_category.dart';

class CategoryCard extends StatefulWidget {
  const CategoryCard({
    required this.category,
    required this.onTap,
    this.isSelected = false,
    super.key,
  });

  final ServiceCategory category;
  final VoidCallback onTap;
  final bool isSelected;

  @override
  State<CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<CategoryCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _scaleController;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) => _scaleController.forward();
  void _onTapUp(TapUpDetails _) => _scaleController.reverse();
  void _onTapCancel() => _scaleController.reverse();

  @override
  Widget build(BuildContext context) {
    final color = widget.category.color;
    final darkColor = HSLColor.fromColor(color)
        .withLightness(
          (HSLColor.fromColor(color).lightness - 0.2).clamp(0.0, 1.0),
        )
        .toColor();
    final lightColor = HSLColor.fromColor(color)
        .withLightness(
          (HSLColor.fromColor(color).lightness + 0.15).clamp(0.0, 1.0),
        )
        .withSaturation(
          (HSLColor.fromColor(color).saturation - 0.1).clamp(0.0, 1.0),
        )
        .toColor();

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: _CardBody(
          category: widget.category,
          isSelected: widget.isSelected,
          color: color,
          darkColor: darkColor,
          lightColor: lightColor,
        ),
      ),
    );
  }
}

class _CardBody extends StatelessWidget {
  const _CardBody({
    required this.category,
    required this.isSelected,
    required this.color,
    required this.darkColor,
    required this.lightColor,
  });

  final ServiceCategory category;
  final bool isSelected;
  final Color color;
  final Color darkColor;
  final Color lightColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 250,
      height: 300,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [lightColor, color, darkColor],
                stops: const [0.0, 0.5, 1.0],
              ),
              border: Border.all(
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.7)
                    : Colors.white.withValues(alpha: 0.25),
                width: isSelected ? 2.5 : 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.4),
                  blurRadius: isSelected ? 30 : 20,
                  spreadRadius: isSelected ? 2 : 0,
                  offset: const Offset(0, 10),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Stack(
              children: [
                _DecorationCircles(color: color, lightColor: lightColor),
                _CardContent(
                  icon: category.icon,
                  name: category.name,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DecorationCircles extends StatelessWidget {
  const _DecorationCircles({
    required this.color,
    required this.lightColor,
  });

  final Color color;
  final Color lightColor;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: -40,
          right: -30,
          child: Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.08),
            ),
          ),
        ),
        Positioned(
          bottom: -50,
          left: -20,
          child: Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.06),
            ),
          ),
        ),
        Positioned(
          top: 60,
          left: -40,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: lightColor.withValues(alpha: 0.15),
            ),
          ),
        ),
      ],
    );
  }
}

class _CardContent extends StatelessWidget {
  const _CardContent({
    required this.icon,
    required this.name,
  });

  final IconData icon;
  final String name;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.15),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
              ),
            ),
            child: Icon(
              icon,
              size: 60,
              color: Colors.white,
              shadows: const [
                Shadow(
                  color: Color(0x40000000),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'OutfitBlack',
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 0.5,
              shadows: [
                Shadow(
                  color: Color(0x40000000),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
