class RecommendedProduct {
  final int productId;
  final String productName;
  final String category;
  final String brand;
  final double price;
  final double rating;
  final String discount;
  final int stock;
  final double confidenceScore;
  final List<String> reasons;

  RecommendedProduct({
    required this.productId,
    required this.productName,
    required this.category,
    required this.brand,
    required this.price,
    required this.rating,
    required this.discount,
    required this.stock,
    required this.confidenceScore,
    required this.reasons,
  });

  factory RecommendedProduct.fromJson(Map<String, dynamic> json) {
    return RecommendedProduct(
      productId: json['product_id'] as int,
      productName: json['product_name'] as String,
      category: json['category'] as String,
      brand: json['brand'] as String,
      price: (json['price'] as num).toDouble(),
      rating: (json['rating'] as num).toDouble(),
      discount: json['discount'] as String,
      stock: json['stock'] as int,
      confidenceScore: (json['confidence_score'] as num).toDouble(),
      reasons: (json['reasons'] as List<dynamic>).map((e) => e as String).toList(),
    );
  }

  double get discountedPrice {
    if (discount == "0%") return price;
    final discountPercentage = double.parse(discount.replaceAll('%', ''));
    return price - (price * discountPercentage / 100);
  }

  String getRandomReason() {
    if (reasons.isEmpty) return "";
    reasons.shuffle();
    return reasons.first;
  }
} 