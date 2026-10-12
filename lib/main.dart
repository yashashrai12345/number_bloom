import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/app_theme.dart';
import 'features/game/application/game_controller.dart';
import 'features/home/presentation/home_screen.dart';
import 'features/settings/application/settings_controller.dart';
import 'services/ads/ads_service.dart';
import 'services/lifecycle/app_lifecycle_service.dart';
import 'services/persistence/local_store.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize local persistence
  final localStore = await LocalStore.create();

  // Initialize ads asynchronously without blocking app launch
  final adsService = AdsService();
  unawaited(adsService.initialize());

  runApp(
    ProviderScope(
      overrides: [
        localStoreProvider.overrideWithValue(localStore),
        adsServiceProvider.overrideWithValue(adsService),
      ],
      child: const NumberBloomApp(),
    ),
  );
}

void unawaited(Future<void> future) {}

class NumberBloomApp extends ConsumerStatefulWidget {
  const NumberBloomApp({super.key});

  @override
  ConsumerState<NumberBloomApp> createState() => _NumberBloomAppState();
}

class _NumberBloomAppState extends ConsumerState<NumberBloomApp> {
  AppLifecycleService? _lifecycleService;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final store = ref.read(localStoreProvider);

      _lifecycleService = AppLifecycleService(
        store: store,
        getGameState: () => ref.read(gameControllerProvider),
        getSettings: () => ref.read(settingsControllerProvider),
      );
      _lifecycleService?.start();
    });
  }

  @override
  void dispose() {
    _lifecycleService?.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsControllerProvider);

    return MaterialApp(
      title: 'Number Bloom',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: settings.themeMode,
      home: const HomeScreen(),
    );
  }
}
