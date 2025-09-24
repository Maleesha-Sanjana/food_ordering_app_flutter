class FoodItem {
  final int id;
  final String name;
  final String? description;
  final double retailPrice;
  final double? wholesalePrice;
  final int? wholesaleMinQuantity;
  final int sellerId;
  final bool isRetailAvailable;
  final bool isWholesaleAvailable;

  const FoodItem({
    required this.id,
    required this.name,
    this.description,
    required this.retailPrice,
    this.wholesalePrice,
    this.wholesaleMinQuantity,
    required this.sellerId,
    this.isRetailAvailable = true,
    this.isWholesaleAvailable = false,
  });

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      retailPrice: (json['retailPrice'] as num).toDouble(),
      wholesalePrice: json['wholesalePrice'] != null
          ? (json['wholesalePrice'] as num).toDouble()
          : null,
      wholesaleMinQuantity: json['wholesaleMinQuantity'] as int?,
      sellerId: json['sellerId'] as int,
      isRetailAvailable: json['isRetailAvailable'] as bool? ?? true,
      isWholesaleAvailable: json['isWholesaleAvailable'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'retailPrice': retailPrice,
    'wholesalePrice': wholesalePrice,
    'wholesaleMinQuantity': wholesaleMinQuantity,
    'sellerId': sellerId,
    'isRetailAvailable': isRetailAvailable,
    'isWholesaleAvailable': isWholesaleAvailable,
  };

  // Helper method to get the appropriate price based on quantity
  double getPriceForQuantity(int quantity, {String type = 'retail'}) {
    if (type == 'wholesale' && isWholesaleAvailable && wholesalePrice != null) {
      if (wholesaleMinQuantity != null && quantity >= wholesaleMinQuantity!) {
        return wholesalePrice!;
      }
    }
    return retailPrice;
  }

  // Helper method to check if wholesale is available for given quantity
  bool canUseWholesale(int quantity) {
    return isWholesaleAvailable &&
        wholesalePrice != null &&
        wholesaleMinQuantity != null &&
        quantity >= wholesaleMinQuantity!;
  }
}
