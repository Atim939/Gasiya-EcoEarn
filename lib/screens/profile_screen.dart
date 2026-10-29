import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/waste_config.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _changePhoto(BuildContext context) async {
    final auth = context.read<AuthProvider>();
    final p = await pickPhoto(context);
    if (p != null) auth.setPhoto(p);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: Stack(
              children: [
                UserAvatar(user: user, radius: 52),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: GestureDetector(
                    onTap: () => _changePhoto(context),
                    child: const CircleAvatar(
                      radius: 16,
                      backgroundColor: AppColors.green,
                      child: Icon(Icons.camera_alt, size: 16, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(user.fullName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          ),
          Center(
            child: Text('${user.phone} · ${user.district}', style: const TextStyle(color: AppColors.muted)),
          ),
          const SectionTitle('Security'),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: user.twoFactor,
            onChanged: auth.setTwoFactor,
            title: const Text('Two-factor authentication'),
            subtitle: const Text('Ask for an SMS code every time you log in'),
          ),
          const SectionTitle('More'),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.groups_outlined),
            title: const Text('About us'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const InfoPage(
                  title: 'About us',
                  paragraphs: [
                    // TODO: replace with your real About Us text.
                    'Gasiya is a community-driven initiative that keeps our towns clean by paying people for the recyclable waste they collect.',
                    'We work with households, schools, markets and local makers across Arua, Gulu, Nebbi and the wider West Nile region.',
                  ],
                ),
              ),
            ),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.info_outline),
            title: const Text('About the app'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const InfoPage(
                  title: 'About the app',
                  paragraphs: [
                    // TODO: replace with your real About the App text.
                    'Request a pickup or drop waste at a collection point, and earn points for every kilo.',
                    'Withdraw your points as cash to MTN or Airtel Money, or spend them on recycled products in the shop.',
                    'Version 1.0.0',
                  ],
                ),
              ),
            ),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.dialpad),
            title: const Text('Using a button phone?'),
            subtitle: Text('Dial $kUssdCode to use Gasiya without a smartphone'),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () {
              Navigator.of(context).popUntil((r) => r.isFirst);
              auth.logout();
            },
            icon: const Icon(Icons.logout),
            label: const Text('Log out'),
          ),
        ],
      ),
    );
  }
}

class InfoPage extends StatelessWidget {
  final String title;
  final List<String> paragraphs;
  const InfoPage({super.key, required this.title, required this.paragraphs});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Icon(Icons.recycling, size: 56, color: AppColors.green),
          const SizedBox(height: 16),
          for (final p in paragraphs)
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Text(p, style: const TextStyle(fontSize: 15, height: 1.5)),
            ),
        ],
      ),
    );
  }
}
