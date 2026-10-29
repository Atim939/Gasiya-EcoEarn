import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/waste_config.dart';
import '../models/models.dart';
import '../providers/app_data.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

/// Lets a user record / list their own recycled product for sale.
class SellProductScreen extends StatefulWidget {
  const SellProductScreen({super.key});

  @override
  State<SellProductScreen> createState() => _SellProductScreenState();
}

class _SellProductScreenState extends State<SellProductScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _desc = TextEditingController();
  final _price = TextEditingController();
  String _category = wasteCategories.first.key;
  String? _photo;

  @override
  void dispose() {
    _name.dispose();
    _desc.dispose();
    _price.dispose();
    super.dispose();
  }

  Future<void> _addPhoto() async {
    final p = await pickPhoto(context);
    if (p != null && mounted) setState(() => _photo = p);
  }

  void _submit() {
    if (!_form.currentState!.validate()) return;
    if (_photo == null) {
      snack(context, 'Please add a photo of your product', error: true);
      return;
    }
    final seller = context.read<AuthProvider>().user.fullName;
    context.read<AppData>().addProduct(Product(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          name: _name.text.trim(),
          description: _desc.text.trim(),
          price: int.parse(_price.text.trim()),
          image: _photo!,
          category: _category,
          seller: seller,
        ));
    Navigator.pop(context);
    snack(context, 'Your product is now in the shop!');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sell your product')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          GestureDetector(
            onTap: _addPhoto,
            child: Container(
              height: 200,
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
                        Icon(Icons.add_a_photo_outlined, size: 36, color: AppColors.muted),
                        SizedBox(height: 8),
                        Text('Add a product photo', style: TextStyle(color: AppColors.muted)),
                      ],
                    )
                  : AppImage(src: _photo),
            ),
          ),
          const SizedBox(height: 16),
          Form(
            key: _form,
            child: Column(
              children: [
                TextFormField(
                  controller: _name,
                  decoration: const InputDecoration(labelText: 'Product name'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter a name' : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _desc,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _price,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Price (UGX)'),
                  validator: (v) {
                    final n = int.tryParse((v ?? '').trim());
                    return (n == null || n <= 0) ? 'Enter a valid price' : null;
                  },
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  value: _category,
                  decoration: const InputDecoration(labelText: 'Made from'),
                  items: wasteCategories
                      .map((c) => DropdownMenuItem(value: c.key, child: Text(c.label)))
                      .toList(),
                  onChanged: (v) => setState(() => _category = v ?? _category),
                ),
                const SizedBox(height: 20),
                WideButton(label: 'List product', icon: Icons.sell_outlined, onPressed: _submit),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
