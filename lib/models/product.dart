class Product {
  final String id;
  final String name;
  final String type;
  final String properties;
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
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String? ?? json['name'].hashCode.toString(),
      name: json['name'] as String,
      type: json['type'] as String,
      properties: json['properties'] as String,
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
    );
  }

  double get discountedPrice {
    if (discount == "0%") return price;
    final discountPercentage = double.parse(discount.replaceAll('%', ''));
    return price - (price * discountPercentage / 100);
  }
} 