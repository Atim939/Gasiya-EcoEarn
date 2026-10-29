import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../config/waste_config.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';

void snack(BuildContext context, String msg, {bool error = false}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(msg),
      behavior: SnackBarBehavior.floating,
      backgroundColor: error ? Theme.of(context).colorScheme.error : null,
    ),
  );
}

/// Shows "camera / gallery" and returns the picked file path (or null).
Future<String?> pickPhoto(BuildContext context) async {
  final source = await showModalBottomSheet<ImageSource>(
    context: context,
    builder: (ctx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.photo_camera_outlined),
            title: const Text('Take a photo'),
            onTap: () => Navigator.pop(ctx, ImageSource.camera),
          ),
          ListTile(
            leading: const Icon(Icons.photo_library_outlined),
            title: const Text('Choose from gallery'),
            onTap: () => Navigator.pop(ctx, ImageSource.gallery),
          ),
        ],
      ),
    ),
  );
  if (source == null) return null;
  final x = await ImagePicker().pickImage(source: source, imageQuality: 70, maxWidth: 1280);
  return x?.path;
}

/// Shows a network URL or a local file path.
class AppImage extends StatelessWidget {
  final String? src;
  final BoxFit fit;
  const AppImage({super.key, required this.src, this.fit = BoxFit.cover});

  @override
  Widget build(BuildContext context) {
    final s = src;
    if (s == null || s.isEmpty) {
      return Container(
        color: AppColors.cream,
        child: const Center(child: Icon(Icons.image_outlined, color: AppColors.muted)),
      );
    }
    Widget broken() => Container(
          color: AppColors.cream,
          child: const Center(child: Icon(Icons.broken_image_outlined, color: AppColors.muted)),
        );
    if (s.startsWith('http')) {
      return Image.network(
        s,
        fit: fit,
        width: double.infinity,
        height: double.infinity,
        loadingBuilder: (c, child, p) => p == null ? child : Container(color: AppColors.cream),
        errorBuilder: (c, e, st) => broken(),
      );
    }
    return Image.file(
      File(s),
      fit: fit,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (c, e, st) => broken(),
    );
  }
}

class UserAvatar extends StatelessWidget {
  final AppUser user;
  final double radius;
  const UserAvatar({super.key, required this.user, this.radius = 24});

  @override
  Widget build(BuildContext context) {
    final p = user.photoPath;
    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.cream,
      backgroundImage: p != null ? FileImage(File(p)) : null,
      child: p == null
          ? Text(
              user.firstName.isNotEmpty ? user.firstName[0].toUpperCase() : '?',
              style: TextStyle(
                fontSize: radius * 0.8,
                fontWeight: FontWeight.bold,
                color: AppColors.greenDark,
              ),
            )
          : null,
    );
  }
}

class WideButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final IconData? icon;
  const WideButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: FilledButton(
        onPressed: loading ? null : onPressed,
        child: loading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[Icon(icon, size: 18), const SizedBox(width: 8)],
                  Text(label),
                ],
              ),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String text;
  final Widget? trailing;
  const SectionTitle(this.text, {super.key, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.slate),
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class StatusChip extends StatelessWidget {
  final String status;
  const StatusChip(this.status, {super.key});

  @override
  Widget build(BuildContext context) {
    Color c;
    switch (status) {
      case 'collected':
      case 'delivered':
      case 'paid':
        c = AppColors.green;
        break;
      case 'scheduled':
        c = AppColors.cyan;
        break;
      case 'pending':
        c = AppColors.amber;
        break;
      default:
        c = AppColors.slate;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: c.withOpacity(0.14),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        status.isEmpty ? '' : status[0].toUpperCase() + status.substring(1),
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: c),
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  const EmptyState({super.key, required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: AppColors.cream,
              child: Icon(icon, size: 28, color: AppColors.muted),
            ),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.muted)),
          ],
        ),
      ),
    );
  }
}

class RewardTile extends StatelessWidget {
  final Reward reward;
  const RewardTile(this.reward, {super.key});

  @override
  Widget build(BuildContext context) {
    final c = reward.isEarned ? AppColors.green : AppColors.slate;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: c.withOpacity(0.12),
        child: Icon(reward.isEarned ? Icons.south_west : Icons.north_east, color: c, size: 18),
      ),
      title: Text(reward.title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(formatDate(reward.createdAt)),
      trailing: Text(
        '${reward.isEarned ? '+' : '-'}${reward.points}',
        style: TextStyle(fontWeight: FontWeight.bold, color: c),
      ),
    );
  }
}

// ---------------- Password strength ----------------

class PasswordStrength {
  final int score; // 0..4
  final String label;
  final Color color;
  const PasswordStrength(this.score, this.label, this.color);
}

PasswordStrength evaluatePassword(String p) {
  if (p.isEmpty) return const PasswordStrength(0, '', AppColors.border);
  var s = 0;
  if (p.length >= 8) s++;
  if (RegExp(r'[A-Z]').hasMatch(p) && RegExp(r'[a-z]').hasMatch(p)) s++;
  if (RegExp(r'\d').hasMatch(p)) s++;
  if (RegExp(r'[^A-Za-z0-9]').hasMatch(p)) s++;
  if (p.length < 8 && s > 1) s = 1;
  switch (s) {
    case 4:
      return const PasswordStrength(4, 'Strong', AppColors.green);
    case 3:
      return const PasswordStrength(3, 'Good', AppColors.cyan);
    case 2:
      return const PasswordStrength(2, 'Fair', AppColors.amber);
    case 1:
      return const PasswordStrength(1, 'Weak', Colors.deepOrange);
    default:
      return const PasswordStrength(0, 'Too weak', Colors.red);
  }
}

class PasswordStrengthMeter extends StatelessWidget {
  final String password;
  const PasswordStrengthMeter(this.password, {super.key});

  @override
  Widget build(BuildContext context) {
    final st = evaluatePassword(password);
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          for (var i = 1; i <= 4; i++)
            Expanded(
              child: Container(
                height: 5,
                margin: EdgeInsets.only(right: i == 4 ? 0 : 4),
                decoration: BoxDecoration(
                  color: i <= st.score ? st.color : AppColors.border,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          const SizedBox(width: 10),
          SizedBox(
            width: 56,
            child: Text(
              st.label,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: st.color),
            ),
          ),
        ],
      ),
    );
  }
}
