import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:game_calendar/app.dart';
import 'package:game_calendar/core/di/injection.dart';
import 'package:game_calendar/features/favorites/data/repositories/favorites_repository.dart';
import 'package:game_calendar/features/favorites/presentation/bloc/favorites_bloc.dart';
import 'package:game_calendar/features/games/data/repositories/games_repository.dart';
import 'package:game_calendar/features/games/presentation/bloc/game_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

      await initHive();
      await Supabase.initialize(url: url, anonKey: anonKey);
      await Supabase.instance.client.auth.signInAnonymously();

      final gamesRepo = await createGamesRepository();
      final favoritesRepo = await createFavoritesRepository();

      if (mounted) {
        setState(() {
          _loading = false;
          _gamesRepo = gamesRepo;
          _favoritesRepo = favoritesRepo;
        });
      }
    } catch (e, st) {
      if (mounted) {
        setState(() {
          _error = 'Init failed: $e\n\n$st';
          _loading = false;
        });
      }
    }
  }

  GamesRepository? _gamesRepo;
  FavoritesRepository? _favoritesRepo;

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return MaterialApp(
        home: const Scaffold(
          body: const Center(child: CircularProgressIndicator()),
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
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<GamesRepository>.value(value: _gamesRepo!),
        RepositoryProvider<FavoritesRepository>.value(value: _favoritesRepo!),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (ctx) => GameBloc(
              gamesRepo: ctx.read<GamesRepository>(),
              favoritesRepo: ctx.read<FavoritesRepository>(),
            )..add(const GameLoadRequested()),
          ),
          BlocProvider(
            create: (ctx) => FavoritesBloc(
              favoritesRepo: ctx.read<FavoritesRepository>(),
              gamesRepo: ctx.read<GamesRepository>(),
            ),
          ),
        ],
        child: const GameCalendarApp(),
      ),
    );
  }
}
