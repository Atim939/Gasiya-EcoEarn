import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/waste_config.dart';
import '../providers/app_data.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/category_card.dart';
import '../widgets/common.dart';
import 'collection_points_screen.dart';
import 'withdraw_screen.dart';

class DashboardScreen extends StatelessWidget {
  final ValueChanged<int> onNavigate;
  const DashboardScreen({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final data = context.watch<AppData>();

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Hello, ${user.firstName} 👋',
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.slate)),
                      const Text('Turn your waste into rewards', style: TextStyle(color: AppColors.muted)),
                    ],
                  ),
                ),
                UserAvatar(user: user, radius: 24),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                gradient: const LinearGradient(
                  colors: [AppColors.green, AppColors.cyan],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Your points', style: TextStyle(color: Colors.white70)),
                  Text('${data.balance}',
                      style: const TextStyle(color: Colors.white, fontSize: 38, fontWeight: FontWeight.w800)),
                  Text('≈ ${formatUGX(data.balance)}', style: const TextStyle(color: AppColors.cream)),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton(
                          style: FilledButton.styleFrom(backgroundColor: Colors.white, foregroundColor: AppColors.greenDark),
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const WithdrawScreen()),
                          ),
                          child: const Text('Withdraw cash'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: FilledButton(
                          style: FilledButton.styleFrom(backgroundColor: AppColors.gold, foregroundColor: AppColors.slate),
                          onPressed: () => onNavigate(2),
                          child: const Text('Spend in shop'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                _Stat(value: '${data.totalKgCollected.toStringAsFixed(1)} kg', label: 'Recycled', color: AppColors.green),
                const SizedBox(width: 10),
                _Stat(value: '${data.pickupsDone}', label: 'Pickups done', color: AppColors.cyan),
                const SizedBox(width: 10),
                _Stat(value: '${data.collections.where((c) => c.status == 'pending').length}', label: 'Pending', color: AppColors.amber),
              ],
            ),
            const SectionTitle('Quick actions'),
            Row(
              children: [
                _Action(icon: Icons.local_shipping_outlined, label: 'Request\npickup', onTap: () => onNavigate(1)),
                _Action(
                  icon: Icons.location_on_outlined,
                  label: 'Drop-off\npoints',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CollectionPointsScreen()),
                  ),
                ),
                _Action(icon: Icons.storefront_outlined, label: 'Shop', onTap: () => onNavigate(2)),
                _Action(icon: Icons.volunteer_activism_outlined, label: 'Impact', onTap: () => onNavigate(3)),
              ],
            ),
            const SectionTitle('What we collect'),
            SizedBox(
              height: 130,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: wasteCategories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (_, i) => CategoryCard(
                  category: wasteCategories[i],
                  width: 160,
                  height: 130,
                  onTap: () => onNavigate(1),
                ),
              ),
            ),
            const SectionTitle('Recent activity'),
            if (data.rewards.isEmpty)
              const EmptyState(icon: Icons.history, message: 'No activity yet.')
            else
              ...data.rewards.take(4).map((r) => RewardTile(r)),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  const _Stat({required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: color)),
            Text(label, style: const TextStyle(fontSize: 11, color: AppColors.muted)),
          ],
        ),
      ),
    );
  }
}

class _Action extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _Action({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: AppColors.cream,
                child: Icon(icon, color: AppColors.greenDark),
              ),
              const SizedBox(height: 6),
              Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, height: 1.2)),
            ],
          ),
        ),
      ),
    );
  }
}
