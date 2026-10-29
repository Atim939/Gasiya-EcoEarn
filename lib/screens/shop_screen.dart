import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/waste_config.dart';
import '../providers/app_data.dart';
import '../providers/cart_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/cart_sheet.dart';
import '../widgets/common.dart';
import '../widgets/product_card.dart';
import 'orders_screen.dart';
import 'sell_product_screen.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  String _query = '';
  String? _categoryKey;

  @override
  Widget build(BuildContext context) {
    final count = context.select<CartProvider, int>((c) => c.count);
    final all = context.watch<AppData>().products;
    final q = _query.trim().toLowerCase();
    final list = all.where((p) {
      final matchCat = _categoryKey == null || p.category == _categoryKey;
      final matchQ = q.isEmpty || p.name.toLowerCase().contains(q) || p.seller.toLowerCase().contains(q);
      return matchCat && matchQ;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shop'),
        actions: [
          IconButton(
            tooltip: 'My orders',
            icon: const Icon(Icons.receipt_long_outlined),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const OrdersScreen()),
            ),
          ),
          IconButton(
            tooltip: 'Cart',
            onPressed: () => showCartSheet(context),
            icon: Badge(
              isLabelVisible: count > 0,
              label: Text('$count'),
              child: const Icon(Icons.shopping_bag_outlined),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.gold,
        foregroundColor: AppColors.slate,
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SellProductScreen()),
        ),
        icon: const Icon(Icons.add_a_photo_outlined),
        label: const Text('Sell yours'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: TextField(
              onChanged: (v) => setState(() => _query = v),
              decoration: const InputDecoration(
                hintText: 'Search recycled products',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: const Text('All'),
                    selected: _categoryKey == null,
                    onSelected: (_) => setState(() => _categoryKey = null),
                  ),
                ),
                for (final c in wasteCategories)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(c.short),
                      selected: _categoryKey == c.key,
                      onSelected: (_) => setState(() => _categoryKey = c.key),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: list.isEmpty
                ? const EmptyState(icon: Icons.search_off, message: 'No products found.')
                : GridView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      mainAxisExtent: 300,
                    ),
                    itemCount: list.length,
                    itemBuilder: (_, i) => ProductCard(product: list[i]),
                  ),
          ),
        ],
      ),
    );
  }
}
