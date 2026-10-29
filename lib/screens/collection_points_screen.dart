import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/waste_config.dart';
import '../models/models.dart';
import '../providers/app_data.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

class CollectionPointsScreen extends StatefulWidget {
  const CollectionPointsScreen({super.key});

  @override
  State<CollectionPointsScreen> createState() => _CollectionPointsScreenState();
}

class _CollectionPointsScreenState extends State<CollectionPointsScreen> {
  String? _district; // null = all

  Future<void> _openMap(CollectionPoint p) async {
    final uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=${p.lat},${p.lng}');
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && mounted) snack(context, 'Could not open maps', error: true);
  }

  Future<void> _call(String phone) async {
    final ok = await launchUrl(Uri(scheme: 'tel', path: phone));
    if (!ok && mounted) snack(context, 'Could not start the call', error: true);
  }

  @override
  Widget build(BuildContext context) {
    final all = context.watch<AppData>().points;
    final list = _district == null ? all : all.where((p) => p.district == _district).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Drop-off points')),
      body: Column(
        children: [
          SizedBox(
            height: 52,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: const Text('All'),
                    selected: _district == null,
                    onSelected: (_) => setState(() => _district = null),
                  ),
                ),
                for (final d in kDistricts)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(d),
                      selected: _district == d,
                      onSelected: (_) => setState(() => _district = d),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: list.isEmpty
                ? const EmptyState(icon: Icons.location_off_outlined, message: 'No points in this area yet.')
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: list.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, i) {
                      final p = list[i];
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
                                const CircleAvatar(
                                  backgroundColor: AppColors.cream,
                                  child: Icon(Icons.location_on, color: AppColors.green),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(p.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                                      Text('${p.address} · ${p.district}',
                                          style: const TextStyle(fontSize: 12, color: AppColors.muted)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                const Icon(Icons.access_time, size: 16, color: AppColors.muted),
                                const SizedBox(width: 6),
                                Text(p.hours, style: const TextStyle(fontSize: 12)),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: p.accepts.map((k) {
                                final c = categoryOf(k);
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: c.bg,
                                    borderRadius: BorderRadius.circular(99),
                                  ),
                                  child: Text(c.short,
                                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: c.color)),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: FilledButton.icon(
                                    onPressed: () => _openMap(p),
                                    icon: const Icon(Icons.directions, size: 18),
                                    label: const Text('Open in Maps'),
                                  ),
                                ),
                                if (p.phone != null) ...[
                                  const SizedBox(width: 10),
                                  OutlinedButton.icon(
                                    onPressed: () => _call(p.phone!),
                                    icon: const Icon(Icons.call_outlined, size: 18),
                                    label: const Text('Call'),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
