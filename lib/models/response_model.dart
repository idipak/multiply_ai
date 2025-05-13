import 'package:multiply_ai/models/product.dart';
import 'package:flutter/material.dart';

class ProductsAnswer {
  final List<Product> products;

  ProductsAnswer({
    required this.products,
  });

  factory ProductsAnswer.fromJson(Map<String, dynamic> json) {
    final productsList = (json['products'] as List)
        .map((productJson) => Product.fromJson(productJson as Map<String, dynamic>))
        .toList();
    
    return ProductsAnswer(
      products: productsList,
    );
  }
}

class AnswerWrapper {
  final ProductsAnswer answer;

  AnswerWrapper({
    required this.answer,
  });

  factory AnswerWrapper.fromJson(Map<String, dynamic> json) {
    return AnswerWrapper(
      answer: ProductsAnswer.fromJson(json['answer'] as Map<String, dynamic>),
    );
  }
}

class VoiceSearchResponse {
  final String userId;
  final String question;
  final AnswerWrapper answer;

  VoiceSearchResponse({
    required this.userId,
    required this.question,
    required this.answer,
  });

  factory VoiceSearchResponse.fromJson(Map<String, dynamic> json) {
    return VoiceSearchResponse(
      userId: json['user_id'] as String,
      question: json['question'] as String,
      answer: AnswerWrapper.fromJson(json['answer'] as Map<String, dynamic>),
    );
  }
}

// Model for filter options
class FilterOptions {
  final List<String> categories;
  final List<String> brands;
  final List<String> materials;
  final RangeValues priceRange;
  final List<String> thicknesses;

  FilterOptions({
    required this.categories,
    required this.brands,
    required this.materials,
    required this.priceRange,
    required this.thicknesses,
  });

  factory FilterOptions.fromJson(Map<String, dynamic> json) {
    return FilterOptions(
      categories: List<String>.from(json['categories'] ?? []),
      brands: List<String>.from(json['brands'] ?? []),
      materials: List<String>.from(json['materials'] ?? []),
      priceRange: RangeValues(
        (json['price_range']?['min'] ?? 0).toDouble(),
        (json['price_range']?['max'] ?? 5000).toDouble(),
      ),
      thicknesses: List<String>.from(json['thicknesses'] ?? []),
    );
  }
} 