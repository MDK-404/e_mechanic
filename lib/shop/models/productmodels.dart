class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String shopName;
  final String shopId; // mechanic id
  final int stockAvailable;
  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.shopName,
    required this.shopId,
    required this.stockAvailable,
  });
}
