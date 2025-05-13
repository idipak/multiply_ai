// class ProductProperties {
//   final String subCategory;
//   final String material;
//   final String waterproof;
//   final String termiteProof;
//   final String fireRated;
//   final String usage;

//   ProductProperties({
//     required this.subCategory,
//     required this.material,
//     required this.waterproof,
//     required this.termiteProof,
//     required this.fireRated,
//     required this.usage,
//   });

//   factory ProductProperties.fromJson(Map<String, dynamic> json) {
//     return ProductProperties(
//       subCategory: json['sub-category'] as String,
//       material: json['material'] as String,
//       waterproof: json['waterproof'] as String,
//       termiteProof: json['termite_proof'] as String,
//       fireRated: json['fire_rated'] as String,
//       usage: json['usage'] as String,
//     );
//   }
// }


import 'dart:convert';

ProductListing productListingFromJson(String str) => ProductListing.fromJson(json.decode(str));

String productListingToJson(ProductListing data) => json.encode(data.toJson());

class ProductListing {
    String userId;
    String question;
    AnswerAnswer answer;

    ProductListing({
        required this.userId,
        required this.question,
        required this.answer,
    });

    factory ProductListing.fromJson(Map<String, dynamic> json) => ProductListing(
        userId: json["user_id"],
        question: json["question"],
        answer: AnswerAnswer.fromJson(json["answer"]),
    );

    Map<String, dynamic> toJson() => {
        "user_id": userId,
        "question": question,
        "answer": answer.toJson(),
    };
}

// class ProductListingAnswer {
//     AnswerAnswer answer;

//     ProductListingAnswer({
//         required this.answer,
//     });

//     factory ProductListingAnswer.fromJson(Map<String, dynamic> json) => ProductListingAnswer(
//         answer: AnswerAnswer.fromJson(json["answer"]),
//     );

//     Map<String, dynamic> toJson() => {
//         "answer": answer.toJson(),
//     };
// }

class AnswerAnswer {
    List<Product> products;

    AnswerAnswer({
        required this.products,
    });

    factory AnswerAnswer.fromJson(Map<String, dynamic> json) => AnswerAnswer(
        products: List<Product>.from(json["products"].map((x) => Product.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "products": List<dynamic>.from(products.map((x) => x.toJson())),
    };
}

class Product {
    dynamic id;
    String name;
    String type;
    List<String> properties;
    String? woodType;
    String? thickness;
    String? dimensions;
    String? color;
    double price;
    String brand;
    bool fireResistant;
    bool termiteResistant;
    double? rating;
    String discount;

    Product({
        required this.id,
        required this.name,
        required this.type,
        required this.properties,
        this.woodType,
        this.thickness,
        this.dimensions,
        this.color,
        required this.price,
        required this.brand,
        required this.fireResistant,
        required this.termiteResistant,
        this.rating,
        required this.discount,
    });


      double get discountedPrice {
    if (discount == "0%") return price;
    final discountPercentage = double.parse(discount.replaceAll('%', ''));
    return price - (price * discountPercentage / 100);
  }

    factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json["ID"],
        name: json["name"],
        type: json["type"],
        properties: List<String>.from(json["properties"]),
        woodType: json["wood_type"],
        thickness: json["thickness"],
        dimensions: json["dimensions"],
        color: json["color"],
        price: json["price"].toDouble(),
        brand: json["brand"],
        fireResistant: json["fire_resistant"],
        termiteResistant: json["termite_resistant"],
        rating: json["rating"]?.toDouble(),
        discount: json["discount"],
    );

    Map<String, dynamic> toJson() => {
        "ID": id,
        "name": name,
        "type": type,
        "properties": properties,  
        "wood_type": woodType,
        "thickness": thickness,
        "dimensions": dimensions,
        "color": color,
        "price": price,
        "brand": brand,
        "fire_resistant": fireResistant,
        "termite_resistant": termiteResistant,
        "rating": rating,
        "discount": discount,
    };
}
