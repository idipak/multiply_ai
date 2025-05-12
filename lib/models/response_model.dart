import 'package:multiply_ai/models/product.dart';

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

class VoiceSearchResponse {
  final String userId;
  final String question;
  final ProductsAnswer answer;

  VoiceSearchResponse({
    required this.userId,
    required this.question,
    required this.answer,
  });

  factory VoiceSearchResponse.fromJson(Map<String, dynamic> json) {
    return VoiceSearchResponse(
      userId: json['user_id'] as String,
      question: json['question'] as String,
      answer: ProductsAnswer.fromJson(json['answer'] as Map<String, dynamic>),
    );
  }
} 