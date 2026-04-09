import 'package:android_cache_cleaner/presentation/pages/about_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:android_cache_cleaner/l10n/generated/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';

void main() {
  setUp(() {
    PackageInfo.setMockInitialValues(
      appName: 'CacheFlow',
      packageName: 'com.sahraouilarbi.android_cache_cleaner',
      version: '1.0.0',
      buildNumber: '1',
      buildSignature: 'signature',
    );
  });

  Widget createWidgetUnderTest({Locale locale = const Locale('en')}) {
    return MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''),
        Locale('fr', ''),
      ],
      locale: locale,
      home: const AboutPage(),
    );
  }

  testWidgets('AboutPage displays app information correctly in English', (WidgetTester tester) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('CacheFlow'), findsOneWidget);
      expect(find.textContaining('Version 1.0.0'), findsOneWidget);
      
      await tester.drag(find.byType(ListView), const Offset(0, -500));
      await tester.pumpAndSettle();

      expect(find.text('Developer'), findsOneWidget);
      expect(find.text('Open Source'), findsOneWidget);
      expect(find.text('Source code on GitHub'), findsOneWidget);
    });
  });

  testWidgets('AboutPage displays app information correctly in French', (WidgetTester tester) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(createWidgetUnderTest(locale: const Locale('fr')));
      await tester.pumpAndSettle();

      expect(find.text('CacheFlow'), findsOneWidget);
      expect(find.textContaining('Version 1.0.0'), findsOneWidget);
      
      await tester.drag(find.byType(ListView), const Offset(0, -500));
      await tester.pumpAndSettle();

      expect(find.text('Développeur'), findsOneWidget);
      expect(find.text('Open Source'), findsOneWidget);
      expect(find.text('Code source sur GitHub'), findsOneWidget);
    });
  });
}
