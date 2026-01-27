import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// A simple skeleton loader widget for loading states
class LoadingSkeleton extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const LoadingSkeleton({
    super.key,
    this.width = double.infinity,
    this.height = 20,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: borderRadius ?? BorderRadius.circular(8),
      ),
    );
  }
}

/// A card skeleton for loading transaction cards
class CardSkeleton extends StatelessWidget {
  const CardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const LoadingSkeleton(width: 50, height: 50, borderRadius: BorderRadius.all(Radius.circular(25))),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LoadingSkeleton(width: double.infinity, height: 16),
                const SizedBox(height: 8),
                LoadingSkeleton(width: 100, height: 14),
              ],
            ),
          ),
          const SizedBox(width: 16),
          const LoadingSkeleton(width: 80, height: 20),
        ],
      ),
    );
  }
}

/// A dashboard skeleton for loading the home screen
class DashboardSkeleton extends StatelessWidget {
  const DashboardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Header skeleton
            Container(
              margin: const EdgeInsets.all(20),
              child: const LoadingSkeleton(width: double.infinity, height: 60),
            ),
            
            // Balance card skeleton
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const LoadingSkeleton(width: 150, height: 30, borderRadius: BorderRadius.all(Radius.circular(4))),
                  const SizedBox(height: 10),
                  const LoadingSkeleton(width: 200, height: 40, borderRadius: BorderRadius.all(Radius.circular(4))),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(child: LoadingSkeleton(height: 40, borderRadius: BorderRadius.all(Radius.circular(8)))),
                      const SizedBox(width: 10),
                      Expanded(child: LoadingSkeleton(height: 40, borderRadius: BorderRadius.all(Radius.circular(8)))),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Stats skeleton
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(child: LoadingSkeleton(height: 100, borderRadius: BorderRadius.all(Radius.circular(12)))),
                  const SizedBox(width: 15),
                  Expanded(child: LoadingSkeleton(height: 100, borderRadius: BorderRadius.all(Radius.circular(12)))),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Chart skeleton
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const LoadingSkeleton(width: double.infinity, height: 200),
            ),
            
            const SizedBox(height: 20),
            
            // Transactions skeleton
            ...List.generate(3, (index) => const CardSkeleton()),
          ],
        ),
      ),
    );
  }
}
