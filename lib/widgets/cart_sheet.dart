import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/waste_config.dart';
import '../providers/app_data.dart';
import '../providers/cart_provider.dart';
import '../theme/app_theme.dart';
import 'common.dart';

/// Flutter version of CartDrawer. Open with: showCartSheet(context)
Future<void> showCartSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => const CartSheet(),
  );
}

class CartSheet extends StatefulWidget {
  const CartSheet({super.key});

  @override
  State<CartSheet> createState() => _CartSheetState();
}

class _CartSheetState extends State<CartSheet> {
  bool _loading = false;
  bool _usePoints = false;

  int _pointsToUse(AppData data, CartProvider cart) =>
      _usePoints ? math.min(data.balance, cart.total.round()) : 0;

  Future<void> _checkout() async {
    final cart = context.read<CartProvider>();
    final data = context.read<AppData>();
    if (cart.items.isEmpty) return;

    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final pointsUsed = _pointsToUse(data, cart);

    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 600)); // TODO: call your API here
    data.placeOrder(items: cart.items, total: cart.total, pointsUsed: pointsUsed);
    cart.clearCart();
    navigator.pop();
    messenger.showSnackBar(const SnackBar(
      behavior: SnackBarBehavior.floating,
      content: Text('Order placed! It is pending. Mobile money payment coming soon.'),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final data = context.watch<AppData>();
    final items = cart.items;
    final pointsUsed = _pointsToUse(data, cart);
    final payable = cart.total - pointsUsed;

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.85,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: Row(
              children: [
                const Icon(Icons.shopping_bag_outlined, color: AppColors.green),
                const SizedBox(width: 8),
                Text(
                  'Your Cart (${cart.count})',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          if (items.isEmpty)
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const EmptyState(icon: Icons.shopping_bag_outlined, message: 'Your cart is empty.'),
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Browse products'),
                  ),
                ],
              ),
            )
          else ...[
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(20),
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (_, i) {
                  final item = items[i];
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: SizedBox(width: 64, height: 64, child: AppImage(src: item.image)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontWeight: FontWeight.w600)),
                            Text(formatUGX(item.price),
                                style: const TextStyle(fontSize: 12, color: AppColors.muted)),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                _QtyButton(
                                  icon: Icons.remove,
                                  onTap: () => cart.updateQuantity(item.productId, item.quantity - 1),
                                ),
                                SizedBox(
                                  width: 32,
                                  child: Text('${item.quantity}',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(fontWeight: FontWeight.w600)),
                                ),
                                _QtyButton(
                                  icon: Icons.add,
                                  onTap: () => cart.updateQuantity(item.productId, item.quantity + 1),
                                ),
                                const Spacer(),
                                IconButton(
                                  visualDensity: VisualDensity.compact,
                                  icon: const Icon(Icons.delete_outline, size: 20, color: AppColors.muted),
                                  onPressed: () => cart.removeItem(item.productId),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            const Divider(height: 1),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (data.balance > 0)
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        value: _usePoints,
                        onChanged: (v) => setState(() => _usePoints = v),
                        title: Text('Use my points (${data.balance} available)'),
                      ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total', style: TextStyle(color: AppColors.muted)),
                        Text(formatUGX(cart.total),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              decoration: pointsUsed > 0 ? TextDecoration.lineThrough : null,
                            )),
                      ],
                    ),
                    if (pointsUsed > 0)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('To pay after $pointsUsed points',
                              style: const TextStyle(color: AppColors.muted)),
                          Text(formatUGX(payable),
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.greenDark)),
                        ],
                      ),
                    const SizedBox(height: 12),
                    WideButton(label: 'Place order', loading: _loading, onPressed: _checkout),
                    const SizedBox(height: 8),
                    const Text('Payment via MTN & Airtel Money coming soon.',
                        style: TextStyle(fontSize: 11, color: AppColors.muted)),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _QtyButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 28,
      height: 28,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.zero,
          minimumSize: const Size(28, 28),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Icon(icon, size: 14),
      ),
    );
  }
}
