class ShopItemEntity {
  final String itemName;
  final String brand;
  final String url;

  ShopItemEntity({
    required this.itemName,
    required this.brand,
    required this.url,
  });

  factory ShopItemEntity.fromJson(Map<String, dynamic> json) {
    return ShopItemEntity(
      itemName: json['item_name'] ?? json['itemName'] ?? '',
      brand: json['brand'] ?? '',
      url: json['url'] ?? '',
    );
  }
}
