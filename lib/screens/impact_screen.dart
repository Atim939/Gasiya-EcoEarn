import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/waste_config.dart';
import '../models/models.dart';
import '../providers/app_data.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

class ImpactScreen extends StatelessWidget {
  const ImpactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Community impact'),
          bottom: const TabBar(
            tabs: [Tab(text: 'Stories'), Tab(text: 'Documents'), Tab(text: 'Reviews')],
          ),
        ),
        body: const TabBarView(children: [_Stories(), _Documents(), _Reviews()]),
      ),
    );
  }
}

class _Stories extends StatelessWidget {
  const _Stories();

  @override
  Widget build(BuildContext context) {
    final data = context.watch<AppData>();
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.cream,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              const Icon(Icons.eco, color: AppColors.green, size: 32),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Your impact', style: TextStyle(fontWeight: FontWeight.w800)),
                    Text('${data.totalKgCollected.toStringAsFixed(1)} kg recycled · '
                        '${data.pickupsDone} pickups completed'),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SectionTitle('Before & after'),
        ...data.stories.map((s) => _StoryCard(s)),
      ],
    );
  }
}

class _StoryCard extends StatelessWidget {
  final ImpactStory story;
  const _StoryCard(this.story);

  @override
  Widget build(BuildContext context) {
    Widget photo(String url, String label) => Expanded(
          child: Stack(
            children: [
              AspectRatio(aspectRatio: 1, child: AppImage(src: url)),
              Positioned(
                left: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.slate.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 11)),
                ),
              ),
            ],
          ),
        );

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [photo(story.before, 'Before'), const SizedBox(width: 2), photo(story.after, 'After')]),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(story.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                Text(story.district, style: const TextStyle(color: AppColors.green, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                Text(story.body),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Documents extends StatelessWidget {
  const _Documents();

  // TODO: replace with real documents/links.
  static const _docs = [
    ('Annual impact report', 'Tonnes collected and families supported', Icons.assessment_outlined),
    ('Household recycling guide', 'How to sort and store your waste', Icons.menu_book_outlined),
    ('Collector safety guide', 'Handling glass, metal and rubber safely', Icons.health_and_safety_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: _docs
          .map((d) => Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: AppColors.border),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.cream,
                    child: Icon(d.$3, color: AppColors.greenDark),
                  ),
                  title: Text(d.$1, style: const TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: Text(d.$2),
                  trailing: const Icon(Icons.download_outlined),
                  onTap: () => snack(context, 'Document coming soon'),
                ),
              ))
          .toList(),
    );
  }
}

class _Reviews extends StatelessWidget {
  const _Reviews();

  Future<void> _write(BuildContext context) async {
    final data = context.read<AppData>();
    final name = context.read<AuthProvider>().user.fullName;
    final ctrl = TextEditingController();
    var rating = 5;
    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: const Text('Write a review'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  5,
                  (i) => IconButton(
                    visualDensity: VisualDensity.compact,
                    onPressed: () => setS(() => rating = i + 1),
                    icon: Icon(i < rating ? Icons.star : Icons.star_border, color: AppColors.gold),
                  ),
                ),
              ),
              TextField(
                controller: ctrl,
                maxLines: 3,
                decoration: const InputDecoration(hintText: 'Share your experience'),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            FilledButton(
              onPressed: () {
                if (ctrl.text.trim().isEmpty) return;
                data.addReview(name, rating, ctrl.text.trim());
                Navigator.pop(ctx);
              },
              child: const Text('Post'),
            ),
          ],
        ),
      ),
    );
    ctrl.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reviews = context.watch<AppData>().reviews;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        OutlinedButton.icon(
          onPressed: () => _write(context),
          icon: const Icon(Icons.rate_review_outlined),
          label: const Text('Write a review'),
        ),
        const SizedBox(height: 12),
        ...reviews.map((r) => Container(
              margin: const EdgeInsets.only(bottom: 12),
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
                      Expanded(child: Text(r.name, style: const TextStyle(fontWeight: FontWeight.w700))),
                      ...List.generate(
                        5,
                        (i) => Icon(i < r.rating ? Icons.star : Icons.star_border,
                            size: 16, color: AppColors.gold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(r.text),
                  const SizedBox(height: 6),
                  Text(formatDate(r.createdAt), style: const TextStyle(fontSize: 11, color: AppColors.muted)),
                ],
              ),
            )),
      ],
    );
  }
}
