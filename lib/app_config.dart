import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static const String appName = 'Expense Tracker';

  static String get supabaseUrl => dotenv.get('SUPABASE_URL');

  static String get supabasePublishableKey =>
      dotenv.get('SUPABASE_PUBLISHABLE_KEY');

  static String get googleWebClientId => dotenv.get('GOOGLE_WEB_CLIENT_ID');

  static String get googleAndroidClientId =>
      dotenv.get('GOOGLE_ANDROID_CLIENT_ID');
}
