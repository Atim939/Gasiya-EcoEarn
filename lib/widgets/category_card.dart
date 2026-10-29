import 'package:flutter/material.dart';
import '../config/waste_config.dart';
import '../theme/app_theme.dart';
import 'common.dart';

/// Waste-type photo card (used on Home and in the pickup request form).
class CategoryCard extends StatelessWidget {
  final WasteCategory category;
  final bool selected;
  final VoidCallback? onTap;
  final double width;
  final double height;

  const CategoryCard({
    super.key,
    required this.category,
    this.selected = false,
    this.onTap,
    this.width = 150,
    this.height = 120,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppColors.green : Colors.transparent,
            width: 3,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(13),
          child: Stack(
            fit: StackFit.expand,
            children: [
              AppImage(src: category.image),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, AppColors.slate.withOpacity(0.85)],
                  ),
                ),
              ),
              Positioned(
                left: 10,
                right: 10,
                bottom: 8,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      category.label,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${category.pointsPerKg} pts/kg',
                      style: const TextStyle(color: AppColors.gold, fontSize: 12, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
              if (selected)
                const Positioned(
                  top: 8,
                  right: 8,
                  child: CircleAvatar(
                    radius: 11,
                    backgroundColor: AppColors.green,
                    child: Icon(Icons.check, size: 14, color: Colors.white),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
