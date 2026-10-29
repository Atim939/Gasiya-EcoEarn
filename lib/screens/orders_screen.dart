import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/waste_config.dart';
import '../providers/app_data.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final orders = context.watch<AppData>().orders;
    return Scaffold(
      appBar: AppBar(title: const Text('My orders')),
      body: orders.isEmpty
          ? const EmptyState(icon: Icons.receipt_long_outlined, message: 'No orders yet.')
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: orders.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) {
                final o = orders[i];
                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(formatDate(o.createdAt), style: const TextStyle(fontWeight: FontWeight.w700)),
                          const Spacer(),
                          StatusChip(o.status),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ...o.items.map((it) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Text('${it.quantity} × ${it.name}'),
                          )),
                      const Divider(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(o.pointsUsed > 0 ? 'Paid with ${o.pointsUsed} points' : 'Pay on mobile money',
                              style: const TextStyle(color: AppColors.muted, fontSize: 12)),
                          Text(formatUGX(o.total), style: const TextStyle(fontWeight: FontWeight.w800)),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
