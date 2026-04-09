import 'package:android_cache_cleaner/domain/entities/app_storage_stats.dart';
import 'package:android_cache_cleaner/domain/usecases/get_app_stats_usecase.dart';
import 'package:android_cache_cleaner/presentation/bloc/storage/storage_bloc.dart';
import 'package:android_cache_cleaner/presentation/bloc/storage/storage_event.dart';
import 'package:android_cache_cleaner/presentation/bloc/storage/storage_state.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockGetAppStatsUseCase extends Mock implements GetAppStatsUseCase {}

void main() {
  late MockGetAppStatsUseCase mockGetAppStatsUseCase;
  late StorageBloc storageBloc;

  setUp(() {
    mockGetAppStatsUseCase = MockGetAppStatsUseCase();
    storageBloc = StorageBloc(mockGetAppStatsUseCase);
  });

  tearDown(() {
    storageBloc.close();
  });

  final tAppList = [
    const AppStorageStats(
      packageName: 'com.test.app',
      appName: 'Test App',
      cacheSize: 1024,
      dataSize: 2048,
      apkSize: 4096,
    ),
  ];

  group('StorageBloc', () {
    test('initial state should be StorageInitial', () {
      expect(storageBloc.state, equals(StorageInitial()));
    });

    blocTest<StorageBloc, StorageState>(
      'emits [StorageLoading, StorageLoaded] when FetchStorageStats is successful',
      build: () {
        when(() => mockGetAppStatsUseCase()).thenAnswer((_) async => tAppList);
        return storageBloc;
      },
      act: (bloc) => bloc.add(FetchStorageStats()),
      expect: () => [
        StorageLoading(),
        StorageLoaded(tAppList, 1024),
      ],
      verify: (_) {
        verify(() => mockGetAppStatsUseCase()).called(1);
      },
    );

    blocTest<StorageBloc, StorageState>(
      'emits [StorageLoading, StorageError] when FetchStorageStats fails',
      build: () {
        when(() => mockGetAppStatsUseCase()).thenThrow(Exception('Failed to fetch'));
        return storageBloc;
      },
      act: (bloc) => bloc.add(FetchStorageStats()),
      expect: () => [
        StorageLoading(),
        const StorageError('Exception: Failed to fetch'),
      ],
    );
  });
}
