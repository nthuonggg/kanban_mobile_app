import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum SessionType { none, cloud, guest }

class AppState extends ChangeNotifier {
  static final AppState instance = AppState._();
  AppState._();

  static const _guestKey = 'guest_mode';

  SessionType _type = SessionType.none;
  SessionType get type => _type;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final isGuest = prefs.getBool(_guestKey) ?? false;
    final session = Supabase.instance.client.auth.currentSession;

    if (session != null) {
      _type = SessionType.cloud;
    } else if (isGuest) {
      _type = SessionType.guest;
    } else {
      _type = SessionType.none;
    }

    Supabase.instance.client.auth.onAuthStateChange.listen((authState) async {
      final hasSession = authState.session != null;
      if (hasSession) {
        await _setGuest(false);
        _type = SessionType.cloud;
        notifyListeners();
      } else if (_type == SessionType.cloud) {
        _type = SessionType.none;
        notifyListeners();
      }
    });
  }

  Future<void> enterGuestMode() async {
    await _setGuest(true);
    _type = SessionType.guest;
    notifyListeners();
  }

  Future<void> signOut() async {
    if (_type == SessionType.cloud) {
      await Supabase.instance.client.auth.signOut();
    }
    await _setGuest(false);
    _type = SessionType.none;
    notifyListeners();
  }

  Future<void> _setGuest(bool v) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_guestKey, v);
  }
}
