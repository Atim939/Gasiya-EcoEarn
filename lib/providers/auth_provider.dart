import 'package:flutter/foundation.dart';
import '../models/models.dart';

class _Account {
  final AppUser user;
  String password;
  _Account(this.user, this.password);
}

/// In-memory auth for demo. Replace the methods with real API/SMS calls
/// (Firebase Phone Auth, Africa's Talking, Twilio Verify, Base44 auth, etc.).
class AuthProvider extends ChangeNotifier {
  static const demoOtp = '123456';

  final Map<String, _Account> _accounts = {
    '0770000000': _Account(
      AppUser(fullName: 'Demo User', phone: '0770000000', district: 'Arua'),
      'Gasiya@123',
    ),
  };

  AppUser? _user;
  bool get isLoggedIn => _user != null;
  AppUser get user => _user!;

  /// +256 770 000 000 / 256770000000 / 0770-000-000  ->  0770000000
  static String normalize(String p) {
    var s = p.replaceAll(RegExp(r'[\s\-()]'), '');
    if (s.startsWith('+256')) {
      s = '0${s.substring(4)}';
    } else if (s.startsWith('256')) {
      s = '0${s.substring(3)}';
    }
    return s;
  }

  bool accountExists(String phone) => _accounts.containsKey(normalize(phone));

  AppUser? checkPassword(String phone, String password) {
    final a = _accounts[normalize(phone)];
    return (a != null && a.password == password) ? a.user : null;
  }

  AppUser? userFor(String phone) => _accounts[normalize(phone)]?.user;

  bool verifyOtp(String code) => code.trim() == demoOtp;

  void signIn(AppUser u) {
    _user = u;
    notifyListeners();
  }

  AppUser register({
    required String fullName,
    required String phone,
    required String district,
    required String password,
  }) {
    final u = AppUser(fullName: fullName, phone: normalize(phone), district: district);
    _accounts[u.phone] = _Account(u, password);
    return u;
  }

  void resetPassword(String phone, String password) {
    _accounts[normalize(phone)]?.password = password;
  }

  void logout() {
    _user = null;
    notifyListeners();
  }

  void setTwoFactor(bool v) {
    _user?.twoFactor = v;
    notifyListeners();
  }

  void setPhoto(String path) {
    _user?.photoPath = path;
    notifyListeners();
  }
}
