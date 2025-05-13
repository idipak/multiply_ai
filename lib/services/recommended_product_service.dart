import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:multiply_ai/services/api_service.dart';
import '../models/recommended_product.dart';

class RecommendedProductService {
  final ApiService _apiService = ApiService();

  Future<List<RecommendedProduct>> getRecommendedProducts() async {
    try {
      // Using the exact API URL as specified in the requirements
      final response = await _apiService.get(
        'api/user/behavior',
      );
      final responseData = response as Map<String, dynamic>;
      final recommendedProductsData = responseData['recommended_products'] as List<dynamic>;
      
      return recommendedProductsData
          .map((productData) => RecommendedProduct.fromJson(productData))
          .toList();
    } catch (e) {
      // Return empty list on error
      return [];
    }
  }
}

// Provider for the service
final recommendedProductServiceProvider = Provider<RecommendedProductService>((ref) {
  return RecommendedProductService();
});

// FutureProvider for recommended products
final recommendedProductsProvider = FutureProvider<List<RecommendedProduct>>((ref) {
  final recommendedProductService = ref.watch(recommendedProductServiceProvider);
  return recommendedProductService.getRecommendedProducts();
}); 