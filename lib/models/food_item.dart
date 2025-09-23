class FoodItem {
  final int id;
  final String name;
  final String? description;
  final double retailPrice;
  final String? wholesaleOptionsJson; // raw JSON string for simplicity
  final int sellerId;

  const FoodItem({
    required this.id,
    required this.name,
    this.description,
    required this.retailPrice,
    this.wholesaleOptionsJson,
    required this.sellerId,
  });

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      retailPrice: (json['retailPrice'] as num).toDouble(),
      wholesaleOptionsJson: json['wholesaleOptions'] as String?,
      sellerId: json['sellerId'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'retailPrice': retailPrice,
    'wholesaleOptions': wholesaleOptionsJson,
    'sellerId': sellerId,
  };
}
