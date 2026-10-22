class Product {
  final int? id;
  final String? name;
  final double? price;
  final String? image;
  final String? description;

  Product({
    this.id,
    this.name,
    this.price,
    this.image,
    this.description,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json["id"],
      name: json["name"],
      price: json["price"]?.toDouble(),
      image: json["image"],
      description: json["description"],
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "price": price,
    "image": image,
    "description": description,
  };
}