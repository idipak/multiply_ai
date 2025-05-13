import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:multiply_ai/services/api_service.dart';
import '../models/product.dart';
import '../models/response_model.dart';

class ProductService {
  final ApiService _apiService = ApiService();
  
  // Fetch products from the API with the new response format
  Future<List<Product>> getProducts(String searchQuery) async {
    try {
      // Call the API with the search query
      final response = await _apiService.post('search/voice', 
        body: {'question': searchQuery}
      );
      
      final voiceSearchResponse = VoiceSearchResponse.fromJson(response);
      return voiceSearchResponse.answer.answer.products;
    } catch (e) {
      print('Error fetching products: $e');
      return [];
    }
  }
  
  // Load filter options from API
  Future<FilterOptions> loadFilterOptions() async {
    try {
      final response = await _apiService.get('product/load-fliter');
      return FilterOptions.fromJson(response);
    } catch (e) {
      print('Error loading filter options: $e');
      // Return default filter options
      return FilterOptions(
        categories: [],
        brands: [],
        materials: [], 
        priceRange: const RangeValues(0, 5000),
        thicknesses: [],
      );
    }
  }
  
  // Apply filters to products
  Future<List<Product>> applyFilters(String filterParams) async {
    try {
      final response = await _apiService.post('product/load-fliter', body: {"question": filterParams});
      final productListing = ProductListing.fromJson(response);
      final productsList = productListing.answer.products;
      return productsList;
    } catch (e) {
      print('Error applying filters: $e');
      return [];
    }
  }
}

// Simple provider for product service
final productServiceProvider = Provider<ProductService>((ref) {
  return ProductService();
});

// FutureProvider for products
final productsProvider = FutureProvider.family<List<Product>, String>((ref, searchQuery) {
  final productService = ref.watch(productServiceProvider);
  return productService.getProducts(searchQuery);
});

// Provider for filter options
final filterOptionsProvider = FutureProvider<FilterOptions>((ref) {
  final productService = ref.watch(productServiceProvider);
  return productService.loadFilterOptions();
});