import 'package:flutter/foundation.dart';
import '../models/models.dart';

class CartProvider extends ChangeNotifier {
  final Map<String, CartItem> _items = {};

  List<CartItem> get items => _items.values.toList();
  int get count => _items.values.fold(0, (s, i) => s + i.quantity);
  num get total => _items.values.fold<num>(0, (s, i) => s + i.price * i.quantity);

  void addItem(Product p) {
    final existing = _items[p.id];
    if (existing != null) {
      existing.quantity++;
    } else {
      _items[p.id] = CartItem.fromProduct(p);
    }
    notifyListeners();
  }

  void updateQuantity(String productId, int quantity) {
    if (quantity <= 0) return removeItem(productId);
    _items[productId]?.quantity = quantity;
    notifyListeners();
  }

  void removeItem(String productId) {
    _items.remove(productId);
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}
