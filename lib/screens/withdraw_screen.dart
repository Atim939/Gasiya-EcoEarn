import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/waste_config.dart';
import '../providers/app_data.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import 'auth_screens.dart';

class WithdrawScreen extends StatefulWidget {
  const WithdrawScreen({super.key});

  @override
  State<WithdrawScreen> createState() => _WithdrawScreenState();
}

class _WithdrawScreenState extends State<WithdrawScreen> {
  final _form = GlobalKey<FormState>();
  final _amount = TextEditingController();
  late final TextEditingController _phone;
  String _method = kMobileMoney.first;

  @override
  void initState() {
    super.initState();
    _phone = TextEditingController(text: context.read<AuthProvider>().user.phone);
  }

  @override
  void dispose() {
    _amount.dispose();
    _phone.dispose();
    super.dispose();
  }

  void _doWithdraw(int amount) {
    final err = context.read<AppData>().withdraw(amount: amount, method: _method, phone: _phone.text);
    if (err != null) {
      snack(context, err, error: true);
    } else {
      _amount.clear();
      snack(context, 'Withdrawal requested. You will receive it on $_method shortly.');
    }
  }

  void _submit() {
    if (!_form.currentState!.validate()) return;
    final amount = int.parse(_amount.text.trim());
    final auth = context.read<AuthProvider>();
    final nav = Navigator.of(context);

    if (amount >= kHighValueWithdrawal) {
      // High-value withdrawals need an OTP.
      nav.push(MaterialPageRoute(
        builder: (_) => OtpScreen(
          phone: auth.user.phone,
          title: 'Confirm withdrawal',
          onVerified: () {
            nav.pop();
            _doWithdraw(amount);
          },
        ),
      ));
    } else {
      _doWithdraw(amount);
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = context.watch<AppData>();
    return Scaffold(
      appBar: AppBar(title: const Text('Withdraw')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppColors.cream, borderRadius: BorderRadius.circular(16)),
            child: Row(
              children: [
                const Icon(Icons.account_balance_wallet_outlined, color: AppColors.greenDark),
                const SizedBox(width: 12),
                Expanded(
                  child: Text('Available: ${data.balance} points (${formatUGX(data.balance)})',
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Form(
            key: _form,
            child: Column(
              children: [
                TextFormField(
                  controller: _amount,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Amount (points = UGX)',
                    helperText:
                        'Minimum ${formatUGX(kMinWithdrawal)}. OTP needed from ${formatUGX(kHighValueWithdrawal)}.',
                  ),
                  validator: (v) {
                    final n = int.tryParse((v ?? '').trim());
                    if (n == null || n <= 0) return 'Enter an amount';
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  value: _method,
                  decoration: const InputDecoration(labelText: 'Send to'),
                  items: kMobileMoney.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                  onChanged: (v) => setState(() => _method = v ?? _method),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _phone,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: 'Mobile money number'),
                  validator: validatePhone,
                ),
                const SizedBox(height: 18),
                WideButton(label: 'Withdraw', icon: Icons.payments_outlined, onPressed: _submit),
              ],
            ),
          ),
          const SectionTitle('History'),
          if (data.rewards.isEmpty)
            const EmptyState(icon: Icons.history, message: 'No transactions yet.')
          else
            ...data.rewards.map((r) => RewardTile(r)),
        ],
      ),
    );
  }
}
