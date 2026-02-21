import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:game_calendar/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AppLoader());
}

class AppLoader extends StatefulWidget {
  const AppLoader({super.key});

  @override
  State<AppLoader> createState() => _AppLoaderState();
}

class _AppLoaderState extends State<AppLoader> {
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      const url =
          String.fromEnvironment('SUPABASE_PROJECT_URL', defaultValue: '');
      const anonKey =
          String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');

      if (url.isEmpty || anonKey.isEmpty) {
        setState(() {
          _error =
              'Missing Supabase config: SUPABASE_PROJECT_URL and SUPABASE_ANON_KEY must be set';
          _loading = false;
        });
        return;
      }

      await Hive.initFlutter();
      await Supabase.initialize(url: url, anonKey: anonKey);
      await Supabase.instance.client.auth.signInAnonymously();
      if (mounted) setState(() => _loading = false);
    } catch (e, st) {
      if (mounted) {
        setState(() {
          _error = 'Init failed: $e\n\n$st';
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return MaterialApp(
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }
    if (_error != null) {
      return MaterialApp(
        home: Scaffold(
          backgroundColor: Colors.red.shade900,
          body: SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: SingleChildScrollView(
                  child: Text(
                    _error!,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }
    return const GameCalendarApp();
  }
}
