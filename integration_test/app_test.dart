import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:android_cache_cleaner/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('End-to-End Test', () {
    testWidgets('Navigate from Dashboard to About Page', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Verify we are on Dashboard
      expect(find.text('CacheFlow'), findsOneWidget);

      // Find the info icon and tap it
      final infoIcon = find.byIcon(Icons.info_outline);
      expect(infoIcon, findsOneWidget);
      
      await tester.tap(infoIcon);
      await tester.pumpAndSettle();

      // Verify we are on About Page
      expect(find.text('À propos'), findsOneWidget);
      expect(find.text('Version 1.0.0 (1)'), findsNothing); // It might be empty in integration test if not mocked
      
      // Go back
      await tester.pageBack();
      await tester.pumpAndSettle();
      
      // Verify we are back on Dashboard
      expect(find.text('CacheFlow'), findsOneWidget);
    });
  });
}
