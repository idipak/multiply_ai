import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/filter_provider.dart';
import '../providers/sort_provider.dart';
import '../services/product_service.dart';
import '../widgets/product_card.dart';
import '../widgets/filter_drawer.dart';
import '../providers/cart_provider.dart';
import 'cart_screen.dart';

class ProductListScreen extends ConsumerWidget {
  const ProductListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncProducts = ref.watch(productsProvider);
    final sortedProducts = ref.watch(sortedProductsProvider);
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
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              Scaffold.of(context).openEndDrawer();
            },
          ),
        ],
      ),
      endDrawer: const FilterDrawer(),
      body: Column(
        children: [
          _buildSortingOptions(context, ref, currentSortOption),
          Expanded(
            child: asyncProducts.when(
              data: (_) => _buildProductGrid(context, sortedProducts, ref),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
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
  
  Widget _buildProductGrid(BuildContext context, List<dynamic> products, WidgetRef ref) {
    if (products.isEmpty) {
      return Center(
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
      );
    }
    
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 1,
        childAspectRatio: 1.8,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        return ProductCard(product: products[index]);
      },
    );
  }
} 