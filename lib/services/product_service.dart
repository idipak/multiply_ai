import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:multiply_ai/services/api_service.dart';
import '../models/product.dart';

class ProductService {
  final ApiService _apiService = ApiService();
  // Simulated API response
  Future<List<Product>> getProducts(String searchQuery) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));
    
    return [
      Product(
        id: "p1",
        name: "BWP Marine Plywood 18mm",
        type: "Plywood",
        properties: "Waterproof",
        woodType: "Hardwood",
        thickness: "18mm",
        dimensions: "8x4 ft",
        color: "Brown",
        price: 1650,
        brand: "GreenPly",
        ecoFriendly: "Yes",
        fireResistant: "Yes",
        termiteResistant: "No",
        recommendedFor: "Bathrooms, Boats",
        rating: 4.7,
        discount: "5%",
        stock: 50
      ),
      Product(
        id: "p2",
        name: "MR Commercial Plywood 12mm",
        type: "Plywood",
        properties: "Interior",
        woodType: "Softwood",
        thickness: "12mm",
        dimensions: "8x4 ft",
        color: "Light Brown",
        price: 1100,
        brand: "Century",
        ecoFriendly: "No",
        fireResistant: "No",
        termiteResistant: "No",
        recommendedFor: "Furniture",
        rating: 4.2,
        discount: "0%",
        stock: 120
      ),
      Product(
        id: "p3",
        name: "Teak Veneer Plywood 19mm",
        type: "Plywood",
        properties: "Premium",
        woodType: "Teak",
        thickness: "19mm",
        dimensions: "8x4 ft",
        color: "Golden",
        price: 2400,
        brand: "Kitply",
        ecoFriendly: "Yes",
        fireResistant: "Yes",
        termiteResistant: "Yes",
        recommendedFor: "Luxury Furniture",
        rating: 4.9,
        discount: "15%",
        stock: 35
      ),
    ];
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