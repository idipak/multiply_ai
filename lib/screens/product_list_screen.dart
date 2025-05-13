import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/filter_provider.dart';
import '../providers/sort_provider.dart';
import '../services/product_service.dart';
import '../widgets/product_card.dart';
import '../widgets/filter_drawer.dart';
import '../providers/cart_provider.dart';
import '../widgets/recommended_products_section.dart';
import 'cart_screen.dart';

class ProductListScreen extends ConsumerWidget {
  final String searchQuery;
  const ProductListScreen({super.key, required this.searchQuery});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final asyncProducts = ref.watch(productsProvider(searchQuery));
    // final sortedProducts = ref.watch(sortedProductsProvider(searchQuery));
    final asyncFilteredProducts = ref.watch(apiFilteredProductsProvider(searchQuery));
    final cartItemCount = ref.watch(cartItemCountProvider);
    final currentSortOption = ref.watch(sortOptionProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Plywood Products',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Badge(
              label: Text(cartItemCount.toString()),
              isLabelVisible: cartItemCount > 0,
              child: const Icon(Icons.shopping_cart_outlined),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CartScreen()),
              );
            },
          ),
        ],
      ),
      endDrawer: const FilterDrawer(),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Text(
                    "Search Results for: ", 
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.blue.shade700,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      searchQuery, 
                      maxLines: 3,
                      style: GoogleFonts.poppins(
                        fontSize: 14, 
                        fontWeight: FontWeight.w500,
                        color: Colors.blue.shade900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: RecommendedProductsSection(),
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: _SortingHeaderDelegate(
              child: _buildSortingOptions(context, ref, currentSortOption),
            ),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 16),
          ),
          asyncFilteredProducts.when(
            data: (filteredProducts) => _buildProductGrid(context, filteredProducts, ref),
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (err, stack) => SliverFillRemaining(
              child: Center(child: Text('Error: $err')),
            ),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 100),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSortingOptions(BuildContext context, WidgetRef ref, SortOption currentSortOption) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Row(
        children: [
          Text(
            'Sort by:',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildSortButton(
                    context, 
                    ref, 
                    'Price: Low to High', 
                    SortOption.priceLowToHigh,
                    currentSortOption,
                  ),
                  const SizedBox(width: 8),
                  _buildSortButton(
                    context, 
                    ref, 
                    'Price: High to Low', 
                    SortOption.priceHighToLow,
                    currentSortOption,
                  ),
                  const SizedBox(width: 8),
                  _buildSortButton(
                    context, 
                    ref, 
                    'Highest Rated', 
                    SortOption.rating,
                    currentSortOption,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortButton(
    BuildContext context, 
    WidgetRef ref, 
    String label, 
    SortOption option,
    SortOption currentOption,
  ) {
    final isSelected = currentOption == option;
    
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Theme.of(context).primaryColor : Colors.white,
        foregroundColor: isSelected ? Colors.white : Colors.black87,
        elevation: isSelected ? 2 : 0,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected ? Colors.transparent : Colors.grey[300]!,
          ),
        ),
      ),
      onPressed: () {
        ref.read(sortOptionProvider.notifier).state = option;
      },
      child: Text(label),
    );
  }
  
  SliverGrid _buildProductGrid(BuildContext context, List<dynamic> products, WidgetRef ref) {
    if (products.isEmpty) {
      return SliverGrid.count(
        crossAxisCount: 1,
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search_off,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No products match your filters',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: () {
                    ref.read(filterProvider.notifier).resetFilters();
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reset Filters'),
                ),
              ],
            ),
          ),
        ],
      );
    }
    
    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 1,
        childAspectRatio: 1.8,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          return ProductCard(product: products[index]);
        },
        childCount: products.length,
      ),
    );
  }
}

class _SortingHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  
  _SortingHeaderDelegate({required this.child});
  
  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }
  
  @override
  double get maxExtent => 60;
  
  @override
  double get minExtent => 60;
  
  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
} 