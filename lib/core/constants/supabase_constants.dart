import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseConstants {
  SupabaseConstants._();

  // Load from --dart-define at compile time
  // static const String supabaseUrl = String.fromEnvironment(
  //   'SUPABASE_URL',
  //   defaultValue: 'YOUR_SUPABASE_URL',
  // );

  // static const String supabaseAnonKey = String.fromEnvironment(
  //   'SUPABASE_ANON_KEY',
  //   defaultValue: 'YOUR_SUPABASE_ANON_KEY',
  // );

  static String get supabaseUrl =>
      dotenv.env['SUPABASE_URL'] ?? 'YOUR_SUPABASE_URL';
  static String get supabaseAnonKey =>
      dotenv.env['SUPABASE_ANON_KEY'] ?? 'YOUR_SUPABASE_ANON_KEY';
}
