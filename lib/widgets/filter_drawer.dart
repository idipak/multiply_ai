import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/filter_provider.dart';
import '../models/product.dart';
import '../models/response_model.dart';
import '../services/product_service.dart';

class FilterDrawer extends ConsumerWidget {
  const FilterDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncFilterOptions = ref.watch(filterOptionsProvider);
    final filterState = ref.watch(filterProvider);
    
    return Drawer(
      child: asyncFilterOptions.when(
        data: (filterOptions) {
          // Get min and max price from API
          final currentRange = filterState.priceRange ?? filterOptions.priceRange;
          
          return SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                _buildHeader(context),
                const SizedBox(height: 24),
                
                // Wood Type Filter
                _buildDropdownFilter(
                  context: context,
                  title: 'Material',
                  items: filterOptions.materials,
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
                  items: filterOptions.thicknesses,
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
                  items: filterOptions.brands,
                  selectedValue: filterState.selectedBrand,
                  onChanged: (value) {
                    ref.read(filterProvider.notifier).setBrand(value);
                  },
                ),
                
                const SizedBox(height: 24),
                
                // Price Range
                _buildPriceRangeFilter(
                  context: context,
                  minPrice: filterOptions.priceRange.start,
                  maxPrice: filterOptions.priceRange.end,
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
          divisions: ((maxPrice - minPrice) ~/ 100).clamp(1, 100),
          labels: RangeLabels(
            '₹${currentRange.start.round()}',
            '₹${currentRange.end.round()}',
          ),
          onChanged: onChanged,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '₹${minPrice.round()}',
                style: GoogleFonts.poppins(
                  color: Colors.grey[600],
                ),
              ),
              Text(
                '₹${maxPrice.round()}',
                style: GoogleFonts.poppins(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
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
          fontWeight: FontWeight.w500,
        ),
      ),
      value: value,
      onChanged: onChanged,
      controlAffinity: ListTileControlAffinity.leading,
      activeColor: Colors.blue,
    );
  }
} 