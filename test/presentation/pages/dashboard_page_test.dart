import 'package:android_cache_cleaner/core/di/injection.dart';
import 'package:android_cache_cleaner/domain/entities/app_storage_stats.dart';
import 'package:android_cache_cleaner/presentation/bloc/cleaning/cleaning_bloc.dart';
import 'package:android_cache_cleaner/presentation/bloc/cleaning/cleaning_event.dart';
import 'package:android_cache_cleaner/presentation/bloc/cleaning/cleaning_state.dart';
import 'package:android_cache_cleaner/presentation/bloc/storage/storage_bloc.dart';
import 'package:android_cache_cleaner/presentation/bloc/storage/storage_event.dart';
import 'package:android_cache_cleaner/presentation/bloc/storage/storage_state.dart';
import 'package:android_cache_cleaner/presentation/pages/dashboard_page.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:android_cache_cleaner/l10n/generated/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockStorageBloc extends MockBloc<StorageEvent, StorageState> implements StorageBloc {}
class MockCleaningBloc extends MockBloc<CleaningEvent, CleaningState> implements CleaningBloc {}

class FakeCleaningEvent extends Fake implements CleaningEvent {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeCleaningEvent());
  });

  late MockStorageBloc mockStorageBloc;
  late MockCleaningBloc mockCleaningBloc;

  setUp(() {
    mockStorageBloc = MockStorageBloc();
    mockCleaningBloc = MockCleaningBloc();

    getIt.reset();
    getIt.registerFactory<StorageBloc>(() => mockStorageBloc);
    getIt.registerFactory<CleaningBloc>(() => mockCleaningBloc);
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
      home: const DashboardPage(),
    );
  }

  testWidgets('renders loading indicator when storage is loading', (tester) async {
    when(() => mockStorageBloc.state).thenReturn(StorageLoading());
    when(() => mockCleaningBloc.state).thenReturn(CleaningInitial());

    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('renders app list and total cache size when storage is loaded', (tester) async {
    final tApps = [
      const AppStorageStats(
        packageName: 'com.test.app',
        appName: 'Test App',
        cacheSize: 1024 * 1024 * 10, // 10 MB
        dataSize: 0,
        apkSize: 0,
      ),
    ];
    when(() => mockStorageBloc.state).thenReturn(StorageLoaded(tApps, 1024 * 1024 * 10));
    when(() => mockCleaningBloc.state).thenReturn(CleaningInitial());

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump();

    expect(find.text('10.0 MB'), findsWidgets);
    expect(find.text('Test App'), findsWidgets);
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });

  testWidgets('renders error message when storage fails', (tester) async {
    when(() => mockStorageBloc.state).thenReturn(const StorageError('Failed to load'));
    when(() => mockCleaningBloc.state).thenReturn(CleaningInitial());

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump();

    expect(find.textContaining('Failed to load'), findsOneWidget);
  });

  testWidgets('triggers cleaning when FAB is pressed', (tester) async {
    final tApps = [
      const AppStorageStats(
        packageName: 'com.test.app',
        appName: 'Test App',
        cacheSize: 1024 * 1024 * 10, // 10 MB
        dataSize: 0,
        apkSize: 0,
      ),
    ];
    when(() => mockStorageBloc.state).thenReturn(StorageLoaded(tApps, 1024 * 1024 * 10));
    when(() => mockCleaningBloc.state).thenReturn(CleaningInitial());

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump();

    await tester.tap(find.byType(FloatingActionButton));
    
    verify(() => mockCleaningBloc.add(any(that: isA<StartCleaning>()))).called(1);
  });
}
