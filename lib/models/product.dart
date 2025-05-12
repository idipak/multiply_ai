class ProductProperties {
  final String subCategory;
  final String material;
  final String waterproof;
  final String termiteProof;
  final String fireRated;
  final String usage;

  ProductProperties({
    required this.subCategory,
    required this.material,
    required this.waterproof,
    required this.termiteProof,
    required this.fireRated,
    required this.usage,
  });

  factory ProductProperties.fromJson(Map<String, dynamic> json) {
    return ProductProperties(
      subCategory: json['sub-category'] as String,
      material: json['material'] as String,
      waterproof: json['waterproof'] as String,
      termiteProof: json['termite_proof'] as String,
      fireRated: json['fire_rated'] as String,
      usage: json['usage'] as String,
    );
  }
}

class Product {
  final int id;
  final String name;
  final String type;
  final ProductProperties properties;
  final String woodType;
  final String thickness;
  final String dimensions;
  final String color;
  final double price;
  final String brand;
  final String ecoFriendly;
  final String fireResistant;
  final String termiteResistant;
  final String recommendedFor;
  final double rating;
  final String discount;
  final int stock;
  final bool isSponsored;

  Product({
    required this.id,
    required this.name,
    required this.type,
    required this.properties,
    required this.woodType,
    required this.thickness,
    required this.dimensions,
    required this.color,
    required this.price,
    required this.brand,
    required this.ecoFriendly,
    required this.fireResistant,
    required this.termiteResistant,
    required this.recommendedFor,
    required this.rating,
    required this.discount,
    required this.stock,
    required this.isSponsored,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['ID'] as int,
      name: json['name'] as String,
      type: json['type'] as String,
      properties: ProductProperties.fromJson(json['properties'] as Map<String, dynamic>),
      woodType: json['wood_type'] as String,
      thickness: json['thickness'] as String,
      dimensions: json['dimensions'] as String,
      color: json['color'] as String,
      price: (json['price'] as num).toDouble(),
      brand: json['brand'] as String,
      ecoFriendly: json['eco_friendly'] as String,
      fireResistant: json['fire_resistant'] as String,
      termiteResistant: json['termite_resistant'] as String,
      recommendedFor: json['recommended_for'] as String,
      rating: (json['rating'] as num).toDouble(),
      discount: json['discount'] as String,
      stock: json['stock'] as int,
      isSponsored: json['isSponsored'] as bool,
    );
  }

  double get discountedPrice {
    if (discount == "0%") return price;
    final discountPercentage = double.parse(discount.replaceAll('%', ''));
    return price - (price * discountPercentage / 100);
  }
} 