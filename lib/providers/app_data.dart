import 'package:flutter/foundation.dart';
import '../config/waste_config.dart';
import '../data/mock_data.dart';
import '../models/models.dart';

/// Holds all app data in memory (products, collections, rewards, orders...).
/// To connect a backend, load/save inside these methods instead.
class AppData extends ChangeNotifier {
  final List<Product> products = mockProducts();
  final List<CollectionPoint> points = mockPoints();
  final List<ImpactStory> stories = mockStories();
  final List<Review> reviews = mockReviews();
  final List<WasteCollection> collections = [];
  final List<Order> orders = [];
  final List<Reward> rewards = [
    Reward(
      id: 'welcome',
      isEarned: true,
      points: 1000,
      title: 'Welcome bonus',
      createdAt: DateTime(2026, 10, 1),
    ),
  ];

  String _id() => DateTime.now().microsecondsSinceEpoch.toString();

  int get balance =>
      rewards.fold(0, (s, r) => r.isEarned ? s + r.points : s - r.points);

  double get totalKgCollected => collections
      .where((c) => c.status == 'collected')
      .fold(0.0, (s, c) => s + c.weightKg);

  int get pickupsDone => collections.where((c) => c.status == 'collected').length;

  // ---- Collections ----
  void requestCollection({
    required String categoryKey,
    required double weightKg,
    required String district,
    required String address,
    String? photoPath,
  }) {
    collections.insert(
      0,
      WasteCollection(
        id: _id(),
        categoryKey: categoryKey,
        weightKg: weightKg,
        district: district,
        address: address,
        photoPath: photoPath,
        createdAt: DateTime.now(),
      ),
    );
    notifyListeners();
  }

  /// DEMO ONLY: in production a collector/admin marks the pickup as done.
  void simulatePickup(String id) {
    final c = collections.firstWhere((c) => c.id == id);
    if (c.status == 'collected') return;
    c.status = 'collected';
    rewards.insert(
      0,
      Reward(
        id: _id(),
        isEarned: true,
        points: c.points,
        title: '${categoryOf(c.categoryKey).short} pickup (${c.weightKg} kg)',
        createdAt: DateTime.now(),
      ),
    );
    notifyListeners();
  }

  // ---- Rewards ----
  /// Returns an error message, or null on success.
  String? withdraw({required int amount, required String method, required String phone}) {
    if (amount < kMinWithdrawal) {
      return 'Minimum withdrawal is ${formatUGX(kMinWithdrawal)}';
    }
    if (amount > balance) return 'You only have $balance points';
    rewards.insert(
      0,
      Reward(
        id: _id(),
        isEarned: false,
        points: amount,
        title: 'Withdrawal to $method ($phone)',
        createdAt: DateTime.now(),
      ),
    );
    notifyListeners();
    return null;
  }

  // ---- Shop ----
  void addProduct(Product p) {
    products.insert(0, p);
    notifyListeners();
  }

  void placeOrder({
    required List<CartItem> items,
    required num total,
    required int pointsUsed,
  }) {
    orders.insert(
      0,
      Order(
        id: _id(),
        items: items,
        total: total,
        pointsUsed: pointsUsed,
        createdAt: DateTime.now(),
      ),
    );
    if (pointsUsed > 0) {
      rewards.insert(
        0,
        Reward(
          id: _id(),
          isEarned: false,
          points: pointsUsed,
          title: 'Points used in shop order',
          createdAt: DateTime.now(),
        ),
      );
    }
    notifyListeners();
  }

  // ---- Impact ----
  void addReview(String name, int rating, String text) {
    reviews.insert(
      0,
      Review(id: _id(), name: name, rating: rating, text: text, createdAt: DateTime.now()),
    );
    notifyListeners();
  }
}
