import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:multiply_ai/services/api_service.dart';
import '../models/product.dart';
import '../models/response_model.dart';

class ProductService {
  final ApiService _apiService = ApiService();
  
  // Fetch products from the API with the new response format
  Future<List<Product>> getProducts(String searchQuery) async {
    try {
      // In a real app, this would call the API using apiService
      // final response = await _apiService.post('search/voice', 
      //   body: {'question': searchQuery}
      // );
      // final voiceSearchResponse = VoiceSearchResponse.fromJson(response);
      // return voiceSearchResponse.answer.products;
      
      // Simulate network delay for now
      await Future.delayed(const Duration(milliseconds: 800));
      
      // Use sample data in the new format
      return _getSampleProducts();
    } catch (e) {
      print('Error fetching products: $e');
      return [];
    }
  }
  
  // Sample data with the new format
  List<Product> _getSampleProducts() {
    // Simulated response based on the new format
    return [
      Product(
        id: 1,
        name: "BWP Marine Plywood 18mm",
        type: "Plywood",
        properties: ProductProperties(
          subCategory: "Waterproof",
          material: "Hardwood",
          waterproof: "Yes",
          termiteProof: "Yes",
          fireRated: "No",
          usage: "Bathrooms, Boats"
        ),
        woodType: "Hardwood",
        thickness: "18mm",
        dimensions: "8x4 ft",
        color: "Brown",
        price: 1650,
        brand: "GreenPly",
        ecoFriendly: "Yes",
        fireResistant: "No",
        termiteResistant: "Yes",
        recommendedFor: "Bathrooms, Boats",
        rating: 4.7,
        discount: "5%",
        stock: 50,
        isSponsored: true
      ),
      Product(
        id: 2,
        name: "MR Commercial Plywood 12mm",
        type: "Plywood",
        properties: ProductProperties(
          subCategory: "Interior",
          material: "Softwood",
          waterproof: "No",
          termiteProof: "No",
          fireRated: "No",
          usage: "Furniture"
        ),
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
        stock: 120,
        isSponsored: true
      ),
      Product(
        id: 4,
        name: "Teak Veneer Plywood 19mm",
        type: "Plywood",
        properties: ProductProperties(
          subCategory: "Premium",
          material: "Teak",
          waterproof: "Yes",
          termiteProof: "Yes",
          fireRated: "Yes",
          usage: "Luxury Furniture"
        ),
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
        stock: 35,
        isSponsored: false
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