import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/cart_item.dart';
import '../models/product.dart';
import '../models/recommended_product.dart';

// Use a simple StateNotifierProvider instead of code generation for now
final cartProvider = StateNotifierProvider<CartNotifier, List<CartItem>>((ref) {
  return CartNotifier();
});

class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super([]);

  void addToCart(Product product) {
    final cartItems = [...state];
    final existingIndex = cartItems.indexWhere(
      (item) => item.product.name == product.name
    );

    if (existingIndex >= 0) {
      // Item already in cart, increment quantity
      cartItems[existingIndex] = cartItems[existingIndex].copyWith(
        quantity: cartItems[existingIndex].quantity + 1
      );
    } else {
      // Add new item to cart
      cartItems.add(CartItem(product: product, quantity: 1));
    }

    state = cartItems;
  }
  
  void addRecommendedProductToCart(RecommendedProduct recommendedProduct) {
    // Convert RecommendedProduct to Product
    final product = Product(
      id: recommendedProduct.productId.toString(),
      name: recommendedProduct.productName,
      type: recommendedProduct.category,
      properties: "",
      woodType: "",
      thickness: "",
      dimensions: "",
      color: "",
      price: recommendedProduct.price,
      brand: recommendedProduct.brand,
      ecoFriendly: "",
      fireResistant: "",
      termiteResistant: "",
      recommendedFor: "",
      rating: recommendedProduct.rating,
      discount: recommendedProduct.discount,
      stock: recommendedProduct.stock,
    );
    
    addToCart(product);
  }

  void removeFromCart(String productName) {
    final cartItems = [...state];
    final existingIndex = cartItems.indexWhere(
      (item) => item.product.name == productName
    );

    if (existingIndex >= 0) {
      if (cartItems[existingIndex].quantity > 1) {
        // Just reduce quantity
        cartItems[existingIndex] = cartItems[existingIndex].copyWith(
          quantity: cartItems[existingIndex].quantity - 1
        );
      } else {
        // Remove item completely
        cartItems.removeAt(existingIndex);
      }
      state = cartItems;
    }
  }

  void removeItemCompletely(String productName) {
    state = state.where((item) => item.product.name != productName).toList();
  }

  void clearCart() {
    state = [];
  }

  double get totalAmount {
    return state.fold(0, (sum, item) => sum + item.totalPrice);
  }

  int get itemCount {
    return state.fold(0, (sum, item) => sum + item.quantity);
  }
}

// Simple computed providers for cart item count and total
final cartItemCountProvider = Provider<int>((ref) {
  final cart = ref.watch(cartProvider);
  return cart.fold(0, (sum, item) => sum + item.quantity);
});

final cartTotalProvider = Provider<double>((ref) {
  final cart = ref.watch(cartProvider);
  return cart.fold(0, (sum, item) => sum + item.totalPrice);
}); 