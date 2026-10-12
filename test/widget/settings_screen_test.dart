import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:number_bloom/core/app_theme.dart';
import 'package:number_bloom/features/settings/application/settings_controller.dart';
import 'package:number_bloom/features/settings/presentation/settings_screen.dart';
import 'package:number_bloom/services/persistence/local_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('SettingsScreen displays theme, haptics, and reduced motion toggles (AC-UI-04, AC-UI-05)', (tester) async {
    final prefs = await SharedPreferences.getInstance();
    final store = LocalStore(prefs);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localStoreProvider.overrideWithValue(store),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const SettingsScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Theme'), findsOneWidget);
    expect(find.text('Reduced Motion'), findsOneWidget);
    expect(find.text('Haptic Feedback'), findsOneWidget);
    expect(find.text('Sound Effects'), findsOneWidget);
    expect(find.text('Privacy Policy'), findsOneWidget);

    // Toggle reduced motion
    final reducedMotionSwitch = find.widgetWithText(SwitchListTile, 'Reduced Motion');
    expect(reducedMotionSwitch, findsOneWidget);
    await tester.tap(reducedMotionSwitch);
    await tester.pumpAndSettle();

    // Verify persisted setting
    final snapshot = store.loadSnapshot();
    expect(snapshot.settings.reducedMotion, isTrue);
  });
}
