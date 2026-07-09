import 'package:flutter/material.dart';
import '../models/category.dart';

class CategoryGrid extends StatelessWidget {
  final void Function(String moduleKey) onTapModule;

  const CategoryGrid({super.key, required this.onTapModule});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: appModules.length,
      itemBuilder: (context, index) {
        final module = appModules[index];
        return InkWell(
          onTap: () => onTapModule(module.key),
          borderRadius: BorderRadius.circular(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFF0057B8).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.center,
                child: Text(module.emoji, style: const TextStyle(fontSize: 26)),
              ),
              const SizedBox(height: 6),
              Text(
                module.label,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
    );
  }
}
