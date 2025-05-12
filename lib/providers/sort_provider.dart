import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product.dart';
import '../providers/filter_provider.dart';

enum SortOption {
  none,
  priceLowToHigh,
  priceHighToLow,
  rating
}

final sortOptionProvider = StateProvider<SortOption>((ref) {
  return SortOption.none;
});

final sortedProductsProvider = Provider.family<List<Product>, String>((ref, searchQuery) {
  final products = ref.watch(filteredProductsProvider(searchQuery));
  final sortOption = ref.watch(sortOptionProvider);
  
  final sortedProducts = [...products];
  
  switch (sortOption) {
    case SortOption.priceLowToHigh:
      sortedProducts.sort((a, b) => a.discountedPrice.compareTo(b.discountedPrice));
      break;
    case SortOption.priceHighToLow:
      sortedProducts.sort((a, b) => b.discountedPrice.compareTo(a.discountedPrice));
      break;
    case SortOption.rating:
      sortedProducts.sort((a, b) => b.rating.compareTo(a.rating));
      break;
    case SortOption.none:
    default:
      // No sorting needed
      break;
  }
  
  return sortedProducts;
}); 