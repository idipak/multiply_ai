import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product.dart';
import '../models/response_model.dart';
import '../services/product_service.dart';

class FilterState {
  final String? selectedWoodType;
  final String? selectedThickness;
  final String? selectedBrand;
  final RangeValues? priceRange;
  final bool? ecoFriendlyOnly;
  final bool? fireResistantOnly;
  final bool? termiteResistantOnly;
  final double? minRating;

  FilterState({
    this.selectedWoodType,
    this.selectedThickness,
    this.selectedBrand,
    this.priceRange,
    this.ecoFriendlyOnly = false,
    this.fireResistantOnly = false,
    this.termiteResistantOnly = false,
    this.minRating,
  });

  FilterState copyWith({
    String? Function()? selectedWoodType,
    String? Function()? selectedThickness,
    String? Function()? selectedBrand,
    RangeValues? Function()? priceRange,
    bool? ecoFriendlyOnly,
    bool? fireResistantOnly,
    bool? termiteResistantOnly,
    double? Function()? minRating,
  }) {
    return FilterState(
      selectedWoodType: selectedWoodType != null ? selectedWoodType() : this.selectedWoodType,
      selectedThickness: selectedThickness != null ? selectedThickness() : this.selectedThickness,
      selectedBrand: selectedBrand != null ? selectedBrand() : this.selectedBrand,
      priceRange: priceRange != null ? priceRange() : this.priceRange,
      ecoFriendlyOnly: ecoFriendlyOnly ?? this.ecoFriendlyOnly,
      fireResistantOnly: fireResistantOnly ?? this.fireResistantOnly,
      termiteResistantOnly: termiteResistantOnly ?? this.termiteResistantOnly,
      minRating: minRating != null ? minRating() : this.minRating,
    );
  }
  
  // Convert to API parameters
  Map<String, dynamic> toApiParams() {
    final params = <String, dynamic>{};
    
    if (selectedWoodType != null) {
      params['wood_type'] = selectedWoodType;
    }
    
    if (selectedThickness != null) {
      params['thickness'] = selectedThickness;
    }
    
    if (selectedBrand != null) {
      params['brand'] = selectedBrand;
    }
    
    if (priceRange != null) {
      params['min_price'] = priceRange!.start;
      params['max_price'] = priceRange!.end;
    }
    
    if (ecoFriendlyOnly == true) {
      params['eco_friendly'] = 'Yes';
    }
    
    if (fireResistantOnly == true) {
      params['fire_resistant'] = 'Yes';
    }
    
    if (termiteResistantOnly == true) {
      params['termite_resistant'] = 'Yes';
    }
    
    if (minRating != null) {
      params['min_rating'] = minRating;
    }
    
    return params;
  }
}

final filterProvider = StateNotifierProvider<FilterNotifier, FilterState>((ref) {
  return FilterNotifier();
});

class FilterNotifier extends StateNotifier<FilterState> {
  FilterNotifier() : super(FilterState());

  void setWoodType(String? woodType) {
    state = state.copyWith(
      selectedWoodType: () => woodType
    );
  }

  void setThickness(String? thickness) {
    state = state.copyWith(
      selectedThickness: () => thickness
    );
  }

  void setBrand(String? brand) {
    state = state.copyWith(
      selectedBrand: () => brand
    );
  }

  void setPriceRange(RangeValues range) {
    state = state.copyWith(
      priceRange: () => range
    );
  }

  void setEcoFriendlyOnly(bool value) {
    state = state.copyWith(
      ecoFriendlyOnly: value
    );
  }

  void setFireResistantOnly(bool value) {
    state = state.copyWith(
      fireResistantOnly: value
    );
  }

  void setTermiteResistantOnly(bool value) {
    state = state.copyWith(
      termiteResistantOnly: value
    );
  }

  void setMinRating(double? rating) {
    state = state.copyWith(
      minRating: () => rating
    );
  }

  void resetFilters() {
    state = FilterState();
  }
}

// Provider for filtered products using the API
final apiFilteredProductsProvider = FutureProvider.family<List<Product>, String>((ref, searchQuery) async {
  final productService = ref.watch(productServiceProvider);
  // final filterState = ref.watch(filterProvider);
  
  // Create filter parameters including search query
  // final params = filterState.toApiParams();
  // params['search_query'] = searchQuery;
  
  // Call API with filter parameters
  return await productService.applyFilters(searchQuery);
});

// Legacy filter provider that filters locally (can be used as fallback)
final filteredProductsProvider = Provider.family<List<Product>, String>((ref, searchQuery) {
  final allProducts = ref.watch(productsProvider(searchQuery)).value ?? [];
  final filters = ref.watch(filterProvider);

  return allProducts.where((product) {
    // Wood type filter
    if (filters.selectedWoodType != null && 
        product.woodType != filters.selectedWoodType) {
      return false;
    }

    // Thickness filter
    if (filters.selectedThickness != null && 
        product.thickness != filters.selectedThickness) {
      return false;
    }

    // Brand filter
    if (filters.selectedBrand != null && 
        product.brand != filters.selectedBrand) {
      return false;
    }

    // Price range filter
    if (filters.priceRange != null) {
      final discountedPrice = product.discountedPrice;
      if (discountedPrice < filters.priceRange!.start || 
          discountedPrice > filters.priceRange!.end) {
        return false;
      }
    }

    // Fire resistant filter
    if (filters.fireResistantOnly == true && 
        product.fireResistant != true) {
      return false;
    }

    // Termite resistant filter
    if (filters.termiteResistantOnly == true && 
        product.termiteResistant != true) {
      return false;
    }

    // Rating filter
    if (filters.minRating != null && 
        product.rating != null &&
        product.rating! < filters.minRating!) {
      return false;
    }

    return true;
  }).toList();
}); 