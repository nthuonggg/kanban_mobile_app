import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseConstants {
  static String get supabaseUrl {
    final v = dotenv.env['SUPABASE_URL'];
    if (v == null || v.isEmpty) {
      throw StateError(
        'Thiếu SUPABASE_URL trong file .env. Tham khảo .env.example.',
      );
    }
    return v;
  }

  static String get supabaseAnonKey {
    final v = dotenv.env['SUPABASE_ANON_KEY'];
    if (v == null || v.isEmpty) {
      throw StateError(
        'Thiếu SUPABASE_ANON_KEY trong file .env. Tham khảo .env.example.',
      );
    }
    return v;
  }
}
