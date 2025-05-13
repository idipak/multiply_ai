import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/recommended_product.dart';
import '../providers/cart_provider.dart';
import '../services/recommended_product_service.dart';
import 'recommended_product_card.dart';

class RecommendedProductsSection extends ConsumerWidget {
  const RecommendedProductsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncRecommendedProducts = ref.watch(recommendedProductsProvider);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                Icon(
                  Icons.recommend,
                  color: Theme.of(context).primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Recommended for You',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 206,
            child: asyncRecommendedProducts.when(
              data: (products) => _buildRecommendedProductsList(products),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const Center(
                child: Text('Failed to load recommendations'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendedProductsList(List<RecommendedProduct> products) {
    if (products.isEmpty) {
      return const Center(
        child: Text('No recommendations available'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      scrollDirection: Axis.horizontal,
      itemCount: products.length,
      itemBuilder: (context, index) {
        return RecommendedProductCard(product: products[index]);
      },
    );
  }
} 