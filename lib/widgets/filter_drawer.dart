import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/filter_provider.dart';
import '../models/product.dart';
import '../services/product_service.dart';

class FilterDrawer extends ConsumerWidget {
  const FilterDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(productsProvider);
    final filterState = ref.watch(filterProvider);
    
    return Drawer(
      child: products.when(
        data: (productList) {
          // Extract unique values for dropdowns
          final woodTypes = _getUniqueValues(productList, (p) => p.woodType);
          final thicknesses = _getUniqueValues(productList, (p) => p.thickness);
          final brands = _getUniqueValues(productList, (p) => p.brand);
          
          // Get min and max price
          double minPrice = 0;
          double maxPrice = 5000; // Default max
          if (productList.isNotEmpty) {
            final prices = productList.map((p) => p.discountedPrice).toList();
            minPrice = prices.reduce((a, b) => a < b ? a : b);
            maxPrice = prices.reduce((a, b) => a > b ? a : b);
            // Round up max price to nearest thousand for better UI
            maxPrice = ((maxPrice / 1000).ceil() * 1000).toDouble();
          }
          
          // Use default range if not set
          final currentRange = filterState.priceRange ?? 
              RangeValues(minPrice, maxPrice);
          
          return SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                _buildHeader(context),
                const SizedBox(height: 24),
                
                // Wood Type Filter
                _buildDropdownFilter(
                  context: context,
                  title: 'Wood Type',
                  items: woodTypes,
                  selectedValue: filterState.selectedWoodType,
                  onChanged: (value) {
                    ref.read(filterProvider.notifier).setWoodType(value);
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Thickness Filter
                _buildDropdownFilter(
                  context: context,
                  title: 'Thickness',
                  items: thicknesses,
                  selectedValue: filterState.selectedThickness,
                  onChanged: (value) {
                    ref.read(filterProvider.notifier).setThickness(value);
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Brand Filter
                _buildDropdownFilter(
                  context: context,
                  title: 'Brand',
                  items: brands,
                  selectedValue: filterState.selectedBrand,
                  onChanged: (value) {
                    ref.read(filterProvider.notifier).setBrand(value);
                  },
                ),
                
                const SizedBox(height: 24),
                
                // Price Range
                _buildPriceRangeFilter(
                  context: context,
                  minPrice: minPrice,
                  maxPrice: maxPrice,
                  currentRange: currentRange,
                  onChanged: (values) {
                    ref.read(filterProvider.notifier).setPriceRange(values);
                  },
                ),
                
                const SizedBox(height: 24),
                
                // Checkbox filters
                _buildCheckboxFilter(
                  title: 'Eco-Friendly Only',
                  value: filterState.ecoFriendlyOnly ?? false,
                  onChanged: (value) {
                    ref.read(filterProvider.notifier).setEcoFriendlyOnly(value!);
                  },
                ),
                
                _buildCheckboxFilter(
                  title: 'Fire-Resistant Only',
                  value: filterState.fireResistantOnly ?? false,
                  onChanged: (value) {
                    ref.read(filterProvider.notifier).setFireResistantOnly(value!);
                  },
                ),
                
                _buildCheckboxFilter(
                  title: 'Termite-Resistant Only',
                  value: filterState.termiteResistantOnly ?? false,
                  onChanged: (value) {
                    ref.read(filterProvider.notifier).setTermiteResistantOnly(value!);
                  },
                ),
                
                const SizedBox(height: 24),
                
                // Reset Button
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[50],
                    foregroundColor: Colors.red[700],
                  ),
                  onPressed: () {
                    ref.read(filterProvider.notifier).resetFilters();
                  },
                  child: const Text('Reset Filters'),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
  
  List<String> _getUniqueValues(List<Product> products, String Function(Product) selector) {
    final set = <String>{};
    for (final product in products) {
      set.add(selector(product));
    }
    return set.toList()..sort();
  }
  
  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Filters',
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
        const Divider(),
        Text(
          'Refine your results',
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
  
  Widget _buildDropdownFilter({
    required BuildContext context,
    required String title,
    required List<String> items,
    required String? selectedValue,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: selectedValue,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            hintText: 'Select $title',
          ),
          items: [
            const DropdownMenuItem<String>(
              value: null,
              child: Text('All'),
            ),
            ...items.map((item) => DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            )),
          ],
          onChanged: onChanged,
        ),
      ],
    );
  }
  
  Widget _buildPriceRangeFilter({
    required BuildContext context,
    required double minPrice,
    required double maxPrice,
    required RangeValues currentRange,
    required Function(RangeValues) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Price Range',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        RangeSlider(
          min: minPrice,
          max: maxPrice,
          values: currentRange,
          divisions: ((maxPrice - minPrice) / 100).round(),
          labels: RangeLabels(
            '₹${currentRange.start.round()}',
            '₹${currentRange.end.round()}',
          ),
          onChanged: onChanged,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '₹${currentRange.start.round()}',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            Text(
              '₹${currentRange.end.round()}',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildCheckboxFilter({
    required String title,
    required bool value,
    required Function(bool?) onChanged,
  }) {
    return CheckboxListTile(
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 16,
        ),
      ),
      value: value,
      onChanged: onChanged,
      dense: true,
      contentPadding: EdgeInsets.zero,
      controlAffinity: ListTileControlAffinity.leading,
    );
  }
} 