import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:number_bloom/core/app_theme.dart';
import 'package:number_bloom/features/game/application/game_controller.dart';
import 'package:number_bloom/features/home/presentation/home_screen.dart';
import 'package:number_bloom/features/settings/application/settings_controller.dart';
import 'package:number_bloom/services/ads/ads_service.dart';
import 'package:number_bloom/services/persistence/local_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('HomeScreen renders brand, best score, and actions (PRD Section 5.4)', (tester) async {
    final prefs = await SharedPreferences.getInstance();
    final store = LocalStore(prefs);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localStoreProvider.overrideWithValue(store),
          adsServiceProvider.overrideWithValue(AdsService()),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const HomeScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify Brand title & subtitle
    expect(find.text('Number Bloom'), findsOneWidget);
    expect(find.text('Merge Puzzle'), findsOneWidget);

    // Verify Best Score card
    expect(find.text('Best Score:'), findsOneWidget);

    // Verify New Garden button
    expect(find.text('New Garden'), findsOneWidget);

    // Verify Settings button icon exists
    expect(find.byIcon(Icons.settings_outlined), findsOneWidget);
  });
}
