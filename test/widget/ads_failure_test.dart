import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:number_bloom/shared/widgets/empty_ad_slot.dart';

void main() {
  testWidgets('AC-ADS-02: BannerAdSlot handles uninitialized or offline state without crashing or blocking', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              Text('Content Above'),
              BannerAdSlot(),
              Text('Content Below'),
            ],
          ),
        ),
      ),
    );

    // Initial pump
    await tester.pump();

    // Verify it doesn't crash or throw and content remains intact
    expect(find.text('Content Above'), findsOneWidget);
    expect(find.text('Content Below'), findsOneWidget);

    // Verify no blocking error dialogs are presented
    expect(find.byType(AlertDialog), findsNothing);
  });
}
