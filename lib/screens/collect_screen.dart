import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/waste_config.dart';
import '../models/models.dart';
import '../providers/app_data.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/category_card.dart';
import '../widgets/common.dart';
import 'collection_points_screen.dart';

class CollectScreen extends StatelessWidget {
  const CollectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Collect'),
          actions: [
            IconButton(
              tooltip: 'Drop-off points',
              icon: const Icon(Icons.map_outlined),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CollectionPointsScreen()),
              ),
            ),
          ],
          bottom: const TabBar(
            tabs: [Tab(text: 'Request pickup'), Tab(text: 'My requests')],
          ),
        ),
        body: const TabBarView(children: [_RequestForm(), _History()]),
      ),
    );
  }
}

class _RequestForm extends StatefulWidget {
  const _RequestForm();

  @override
  State<_RequestForm> createState() => _RequestFormState();
}

class _RequestFormState extends State<_RequestForm> {
  final _form = GlobalKey<FormState>();
  final _weight = TextEditingController();
  final _address = TextEditingController();
  String _categoryKey = wasteCategories.first.key;
  late String _district;
  String? _photo;

  @override
  void initState() {
    super.initState();
    final d = context.read<AuthProvider>().user.district;
    _district = kDistricts.contains(d) ? d : kDistricts.first;
  }

  @override
  void dispose() {
    _weight.dispose();
    _address.dispose();
    super.dispose();
  }

  double get _kg => double.tryParse(_weight.text.trim()) ?? 0;

  Future<void> _addPhoto() async {
    final p = await pickPhoto(context);
    if (p != null && mounted) setState(() => _photo = p);
  }

  void _submit() {
    if (!_form.currentState!.validate()) return;
    context.read<AppData>().requestCollection(
          categoryKey: _categoryKey,
          weightKg: _kg,
          district: _district,
          address: _address.text.trim(),
          photoPath: _photo,
        );
    _weight.clear();
    _address.clear();
    setState(() => _photo = null);
    snack(context, 'Pickup requested! A collector will contact you.');
    DefaultTabController.of(context).animateTo(1);
  }

  @override
  Widget build(BuildContext context) {
    final cat = categoryOf(_categoryKey);
    final cardW = (MediaQuery.of(context).size.width - 32 - 12) / 2;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('1. What are you recycling?', style: TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: wasteCategories
              .map((c) => CategoryCard(
                    category: c,
                    width: cardW,
                    height: 110,
                    selected: c.key == _categoryKey,
                    onTap: () => setState(() => _categoryKey = c.key),
                  ))
              .toList(),
        ),
        const SizedBox(height: 20),
        Form(
          key: _form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('2. Details', style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 10),
              TextFormField(
                controller: _weight,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  labelText: 'Estimated weight (kg)',
                  prefixIcon: Icon(Icons.scale_outlined),
                ),
                validator: (v) {
                  final n = double.tryParse((v ?? '').trim());
                  return (n == null || n <= 0) ? 'Enter the weight in kg' : null;
                },
              ),
              if (_kg > 0)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    "You'll earn about ${(_kg * cat.pointsPerKg).round()} points",
                    style: const TextStyle(color: AppColors.greenDark, fontWeight: FontWeight.w700),
                  ),
                ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                value: _district,
                decoration: const InputDecoration(
                  labelText: 'District',
                  prefixIcon: Icon(Icons.location_city_outlined),
                ),
                items: kDistricts.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                onChanged: (v) => setState(() => _district = v ?? _district),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _address,
                decoration: const InputDecoration(
                  labelText: 'Pickup location / landmark',
                  prefixIcon: Icon(Icons.place_outlined),
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Tell us where to collect' : null,
              ),
              const SizedBox(height: 20),
              const Text('3. Add a photo (optional)', style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: _addPhoto,
                child: Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.cream,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: _photo == null
                      ? const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_a_photo_outlined, size: 32, color: AppColors.muted),
                            SizedBox(height: 6),
                            Text('Tap to take or upload a photo', style: TextStyle(color: AppColors.muted)),
                          ],
                        )
                      : AppImage(src: _photo),
                ),
              ),
              const SizedBox(height: 24),
              WideButton(label: 'Request pickup', icon: Icons.local_shipping_outlined, onPressed: _submit),
            ],
          ),
        ),
      ],
    );
  }
}

class _History extends StatelessWidget {
  const _History();

  @override
  Widget build(BuildContext context) {
    final data = context.watch<AppData>();
    if (data.collections.isEmpty) {
      return const EmptyState(
        icon: Icons.local_shipping_outlined,
        message: 'No pickup requests yet.\nRequest one to start earning points.',
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: data.collections.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) => _CollectionCard(data.collections[i]),
    );
  }
}

class _CollectionCard extends StatelessWidget {
  final WasteCollection c;
  const _CollectionCard(this.c);

  @override
  Widget build(BuildContext context) {
    final cat = categoryOf(c.categoryKey);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(width: 64, height: 64, child: AppImage(src: c.photoPath ?? cat.image)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${cat.short} · ${c.weightKg} kg', style: const TextStyle(fontWeight: FontWeight.w700)),
                    Text(c.address, maxLines: 1, overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: AppColors.muted, fontSize: 12)),
                    Text(formatDate(c.createdAt), style: const TextStyle(color: AppColors.muted, fontSize: 12)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  StatusChip(c.status),
                  const SizedBox(height: 6),
                  Text('+${c.points} pts',
                      style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.greenDark)),
                ],
              ),
            ],
          ),
          if (c.status == 'pending')
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => context.read<AppData>().simulatePickup(c.id),
                child: const Text('Simulate pickup (demo)'),
              ),
            ),
        ],
      ),
    );
  }
}
