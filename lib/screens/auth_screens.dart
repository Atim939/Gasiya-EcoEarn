import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/waste_config.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

String? validatePhone(String? v) {
  final p = AuthProvider.normalize(v ?? '');
  return RegExp(r'^0\d{9}$').hasMatch(p) ? null : 'Enter a valid phone number (e.g. 0770 000 000)';
}

String? validateNewPassword(String? v) {
  if (v == null || v.isEmpty) return 'Enter a password';
  if (evaluatePassword(v).score < 2) return 'Use 8+ characters with letters and numbers';
  return null;
}

/// Hero artwork on top + white floating card with the form.
class AuthScaffold extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;
  final bool showBack;

  const AuthScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
    this.showBack = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SingleChildScrollView(
        child: Stack(
          children: [
            SizedBox(
              height: 300,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  const AppImage(src: 'https://picsum.photos/seed/gasiya-hero/900/700'),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.green.withOpacity(0.55),
                          AppColors.slate.withOpacity(0.9),
                        ],
                      ),
                    ),
                  ),
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (showBack)
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.arrow_back, color: Colors.white),
                            )
                          else
                            const SizedBox(height: 48),
                          const Spacer(),
                          const Row(
                            children: [
                              Icon(Icons.recycling, color: AppColors.gold, size: 30),
                              SizedBox(width: 8),
                              Text('Gasiya',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(title,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800)),
                          const SizedBox(height: 2),
                          Text(subtitle, style: const TextStyle(color: Colors.white70)),
                          const SizedBox(height: 60),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 250, 16, 24),
              child: Material(
                color: Colors.white,
                elevation: 6,
                shadowColor: Colors.black26,
                borderRadius: BorderRadius.circular(24),
                child: Padding(padding: const EdgeInsets.all(20), child: child),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ------------------------------------------------------------------ LOGIN

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _phone = TextEditingController();
  final _pw = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _phone.dispose();
    _pw.dispose();
    super.dispose();
  }

  void _login() {
    if (!_form.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final nav = Navigator.of(context);
    final u = auth.checkPassword(_phone.text, _pw.text);
    if (u == null) {
      snack(context, 'Wrong phone number or password', error: true);
      return;
    }
    if (u.twoFactor) {
      nav.push(MaterialPageRoute(
        builder: (_) => OtpScreen(
          phone: u.phone,
          title: 'Two-factor check',
          onVerified: () {
            nav.popUntil((r) => r.isFirst);
            auth.signIn(u);
          },
        ),
      ));
    } else {
      auth.signIn(u);
    }
  }

  void _loginWithOtp() {
    final err = validatePhone(_phone.text);
    if (err != null) {
      snack(context, err, error: true);
      return;
    }
    final auth = context.read<AuthProvider>();
    final nav = Navigator.of(context);
    final u = auth.userFor(_phone.text);
    if (u == null) {
      snack(context, 'No account found for that number', error: true);
      return;
    }
    nav.push(MaterialPageRoute(
      builder: (_) => OtpScreen(
        phone: u.phone,
        title: 'Log in with OTP',
        onVerified: () {
          nav.popUntil((r) => r.isFirst);
          auth.signIn(u);
        },
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Welcome back',
      subtitle: 'Log in to keep recycling and earning',
      child: Form(
        key: _form,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _phone,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Phone number',
                prefixIcon: Icon(Icons.phone_outlined),
              ),
              validator: validatePhone,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _pw,
              obscureText: _obscure,
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
              ),
              validator: (v) => (v == null || v.isEmpty) ? 'Enter your password' : null,
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
                ),
                child: const Text('Forgot password?'),
              ),
            ),
            WideButton(label: 'Log in', onPressed: _login),
            TextButton(onPressed: _loginWithOtp, child: const Text('Log in with OTP instead')),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('New here?'),
                TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RegisterScreen()),
                  ),
                  child: const Text('Create account'),
                ),
              ],
            ),
            const Text(
              'Demo account: 0770000000 / Gasiya@123',
              style: TextStyle(fontSize: 11, color: AppColors.muted),
            ),
          ],
        ),
      ),
    );
  }
}

// ------------------------------------------------------------------ REGISTER

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _pw = TextEditingController();
  final _confirm = TextEditingController();
  String _district = kDistricts.first;
  bool _obscure = true;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _pw.dispose();
    _confirm.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_form.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final nav = Navigator.of(context);
    if (auth.accountExists(_phone.text)) {
      snack(context, 'That number already has an account. Try logging in.', error: true);
      return;
    }
    final name = _name.text.trim();
    final phone = _phone.text;
    final pw = _pw.text;
    final district = _district;
    nav.push(MaterialPageRoute(
      builder: (_) => OtpScreen(
        phone: AuthProvider.normalize(phone),
        title: 'Verify your number',
        onVerified: () {
          final u = auth.register(fullName: name, phone: phone, district: district, password: pw);
          nav.popUntil((r) => r.isFirst);
          auth.signIn(u);
        },
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      showBack: true,
      title: 'Create account',
      subtitle: 'Start earning from your waste',
      child: Form(
        key: _form,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _name,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Full name',
                prefixIcon: Icon(Icons.person_outline),
              ),
              validator: (v) => (v == null || v.trim().length < 2) ? 'Enter your name' : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _phone,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Phone number',
                prefixIcon: Icon(Icons.phone_outlined),
              ),
              validator: validatePhone,
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              value: _district,
              decoration: const InputDecoration(
                labelText: 'District',
                prefixIcon: Icon(Icons.location_on_outlined),
              ),
              items: kDistricts.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
              onChanged: (v) => setState(() => _district = v ?? _district),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _pw,
              obscureText: _obscure,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
              ),
              validator: validateNewPassword,
            ),
            PasswordStrengthMeter(_pw.text),
            const SizedBox(height: 14),
            TextFormField(
              controller: _confirm,
              obscureText: _obscure,
              decoration: const InputDecoration(
                labelText: 'Confirm password',
                prefixIcon: Icon(Icons.lock_outline),
              ),
              validator: (v) => v != _pw.text ? 'Passwords do not match' : null,
            ),
            const SizedBox(height: 18),
            WideButton(label: 'Continue', onPressed: _submit),
          ],
        ),
      ),
    );
  }
}

// ------------------------------------------------------------------ OTP

class OtpScreen extends StatefulWidget {
  final String phone;
  final String title;
  final VoidCallback onVerified;

  const OtpScreen({
    super.key,
    required this.phone,
    required this.title,
    required this.onVerified,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _code = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  void _verify() {
    if (context.read<AuthProvider>().verifyOtp(_code.text)) {
      widget.onVerified();
    } else {
      setState(() => _error = 'Incorrect code. Try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      showBack: true,
      title: widget.title,
      subtitle: 'Code sent by SMS to ${widget.phone}',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _code,
            keyboardType: TextInputType.number,
            maxLength: 6,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 26, letterSpacing: 10, fontWeight: FontWeight.w700),
            decoration: InputDecoration(counterText: '', hintText: '------', errorText: _error),
            onChanged: (_) => setState(() => _error = null),
          ),
          const SizedBox(height: 6),
          const Text(
            'Demo code: ${AuthProvider.demoOtp}',
            style: TextStyle(fontSize: 12, color: AppColors.muted),
          ),
          const SizedBox(height: 16),
          WideButton(label: 'Verify', onPressed: _verify),
          TextButton(
            onPressed: () => snack(context, 'A new code has been sent'),
            child: const Text('Resend code'),
          ),
        ],
      ),
    );
  }
}

// ------------------------------------------------------------------ FORGOT PASSWORD

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _form = GlobalKey<FormState>();
  final _phone = TextEditingController();

  @override
  void dispose() {
    _phone.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_form.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final nav = Navigator.of(context);
    if (!auth.accountExists(_phone.text)) {
      snack(context, 'No account found for that number', error: true);
      return;
    }
    final phone = AuthProvider.normalize(_phone.text);
    nav.push(MaterialPageRoute(
      builder: (_) => OtpScreen(
        phone: phone,
        title: 'Reset password',
        onVerified: () => nav.pushReplacement(
          MaterialPageRoute(builder: (_) => ResetPasswordScreen(phone: phone)),
        ),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      showBack: true,
      title: 'Forgot password?',
      subtitle: "We'll text you a code to reset it",
      child: Form(
        key: _form,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _phone,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Phone number',
                prefixIcon: Icon(Icons.phone_outlined),
              ),
              validator: validatePhone,
            ),
            const SizedBox(height: 18),
            WideButton(label: 'Send code', onPressed: _submit),
          ],
        ),
      ),
    );
  }
}

class ResetPasswordScreen extends StatefulWidget {
  final String phone;
  const ResetPasswordScreen({super.key, required this.phone});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _form = GlobalKey<FormState>();
  final _pw = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _pw.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_form.currentState!.validate()) return;
    final messenger = ScaffoldMessenger.of(context);
    context.read<AuthProvider>().resetPassword(widget.phone, _pw.text);
    Navigator.of(context).popUntil((r) => r.isFirst);
    messenger.showSnackBar(const SnackBar(
      behavior: SnackBarBehavior.floating,
      content: Text('Password updated. Please log in.'),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      showBack: true,
      title: 'New password',
      subtitle: 'Choose something strong',
      child: Form(
        key: _form,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _pw,
              obscureText: _obscure,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                labelText: 'New password',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
              ),
              validator: validateNewPassword,
            ),
            PasswordStrengthMeter(_pw.text),
            const SizedBox(height: 18),
            WideButton(label: 'Save password', onPressed: _submit),
          ],
        ),
      ),
    );
  }
}
