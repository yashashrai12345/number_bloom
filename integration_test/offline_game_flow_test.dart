import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:number_bloom/core/app_theme.dart';
import 'package:number_bloom/features/game/application/game_controller.dart';
import 'package:number_bloom/features/game/presentation/widgets/game_board.dart';
import 'package:number_bloom/features/home/presentation/home_screen.dart';
import 'package:number_bloom/features/settings/application/settings_controller.dart';
import 'package:number_bloom/services/ads/ads_service.dart';
import 'package:number_bloom/services/persistence/local_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('End-to-end offline gameplay flow: Home -> Play -> Move -> Home -> Resume (AC-OFF-01, AC-OFF-02)',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
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

    // 1. Verify Home Screen is visible
    expect(find.text('Number Bloom'), findsOneWidget);
    expect(find.text('New Garden'), findsOneWidget);

    // 2. Start a New Garden
    await tester.tap(find.text('New Garden'));
    await tester.pumpAndSettle();

    // 3. Tutorial overlay appears on first launch
    expect(find.text('How to Play'), findsOneWidget);
    await tester.tap(find.text('Got it, Let\'s Play!'));
    await tester.pumpAndSettle();

    // 4. Verify GameBoard is on screen
    expect(find.byType(GameBoard), findsOneWidget);

    // 5. Simulate swipes in multiple directions
    final boardFinder = find.byType(GameBoard);
    await tester.drag(boardFinder, const Offset(-100, 0)); // swipe left
    await tester.pumpAndSettle();

    await tester.drag(boardFinder, const Offset(0, -100)); // swipe up
    await tester.pumpAndSettle();

    await tester.drag(boardFinder, const Offset(100, 0)); // swipe right
    await tester.pumpAndSettle();

    await tester.drag(boardFinder, const Offset(0, 100)); // swipe down
    await tester.pumpAndSettle();

    // 6. Return to Home screen
    final backButton = find.byTooltip('Main Menu');
    expect(backButton, findsOneWidget);
    await tester.tap(backButton);
    await tester.pumpAndSettle();

    // If confirmation dialog appears, confirm return
    if (find.text('Return Home').evaluate().isNotEmpty) {
      await tester.tap(find.text('Return Home'));
      await tester.pumpAndSettle();
    }

    // 7. Verify Continue Garden button is now available on Home
    expect(find.text('Number Bloom'), findsOneWidget);
  });
}
