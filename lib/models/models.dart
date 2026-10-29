import '../config/waste_config.dart';

/// These mirror your Base44 entities (User, Product, Order, Reward,
/// WasteCollection, CollectionPoint). Adjust fields if your JSON differs.

class AppUser {
  String fullName;
  String phone;
  String district;
  String? photoPath;
  bool twoFactor;

  AppUser({
    required this.fullName,
    required this.phone,
    required this.district,
    this.photoPath,
    this.twoFactor = false,
  });

  String get firstName => fullName.trim().split(' ').first;
}

class Product {
  final String id;
  final String name;
  final String? description;
  final num price;
  final String image; // http(s) URL or local file path
  final String category; // WasteCategory.key
  final String seller;

  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.image,
    required this.category,
    this.description,
    this.seller = 'Gasiya Marketplace',
  });
}

class CartItem {
  final String productId;
  final String name;
  final num price;
  final String image;
  int quantity;

  CartItem({
    required this.productId,
    required this.name,
    required this.price,
    required this.image,
    this.quantity = 1,
  });

  factory CartItem.fromProduct(Product p) =>
      CartItem(productId: p.id, name: p.name, price: p.price, image: p.image);

  Map<String, dynamic> toJson() => {
        'product_id': productId,
        'name': name,
        'price': price,
        'image': image,
        'quantity': quantity,
      };
}

class Order {
  final String id;
  final List<CartItem> items;
  final num total;
  final int pointsUsed;
  String status; // pending | paid | delivered
  final DateTime createdAt;

  Order({
    required this.id,
    required this.items,
    required this.total,
    required this.pointsUsed,
    this.status = 'pending',
    required this.createdAt,
  });
}

class WasteCollection {
  final String id;
  final String categoryKey;
  final double weightKg;
  final String district;
  final String address;
  final String? photoPath;
  String status; // pending | collected
  final DateTime createdAt;

  WasteCollection({
    required this.id,
    required this.categoryKey,
    required this.weightKg,
    required this.district,
    required this.address,
    this.photoPath,
    this.status = 'pending',
    required this.createdAt,
  });

  int get points => (weightKg * categoryOf(categoryKey).pointsPerKg).round();
}

class Reward {
  final String id;
  final bool isEarned; // false = redeemed / withdrawn
  final int points;
  final String title;
  final DateTime createdAt;

  const Reward({
    required this.id,
    required this.isEarned,
    required this.points,
    required this.title,
    required this.createdAt,
  });
}

class CollectionPoint {
  final String id;
  final String name;
  final String district;
  final String address;
  final String hours;
  final String? phone;
  final double lat;
  final double lng;
  final List<String> accepts; // WasteCategory keys

  const CollectionPoint({
    required this.id,
    required this.name,
    required this.district,
    required this.address,
    required this.hours,
    required this.lat,
    required this.lng,
    required this.accepts,
    this.phone,
  });
}

class ImpactStory {
  final String id;
  final String title;
  final String district;
  final String body;
  final String before;
  final String after;

  const ImpactStory({
    required this.id,
    required this.title,
    required this.district,
    required this.body,
    required this.before,
    required this.after,
  });
}

class Review {
  final String id;
  final String name;
  final int rating;
  final String text;
  final DateTime createdAt;

  Review({
    required this.id,
    required this.name,
    required this.rating,
    required this.text,
    required this.createdAt,
  });
}
