// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

import '../../data/datasources/native_channel.dart' as _i66;
import '../../data/repositories/cleaning_repository_impl.dart' as _i51;
import '../../data/repositories/storage_repository_impl.dart' as _i47;
import '../../domain/repositories/i_cleaning_repository.dart' as _i1058;
import '../../domain/repositories/i_storage_repository.dart' as _i568;
import '../../domain/usecases/clean_cache_usecase.dart' as _i700;
import '../../domain/usecases/get_app_stats_usecase.dart' as _i463;
import '../../presentation/bloc/cleaning/cleaning_bloc.dart' as _i1012;
import '../../presentation/bloc/storage/storage_bloc.dart' as _i110;

extension GetItInjectableX on _i174.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    gh.lazySingleton<_i66.NativeChannel>(() => _i66.NativeChannel());
    gh.factory<_i568.IStorageRepository>(
        () => _i47.StorageRepositoryImpl(gh<_i66.NativeChannel>()));
    gh.factory<_i1058.ICleaningRepository>(
        () => _i51.CleaningRepositoryImpl(gh<_i66.NativeChannel>()));
    gh.factory<_i700.CleanCacheUseCase>(
        () => _i700.CleanCacheUseCase(gh<_i1058.ICleaningRepository>()));
    gh.factory<_i1012.CleaningBloc>(() => _i1012.CleaningBloc(
          gh<_i700.CleanCacheUseCase>(),
          gh<_i1058.ICleaningRepository>(),
        ));
    gh.factory<_i463.GetAppStatsUseCase>(
        () => _i463.GetAppStatsUseCase(gh<_i568.IStorageRepository>()));
    gh.factory<_i110.StorageBloc>(
        () => _i110.StorageBloc(gh<_i463.GetAppStatsUseCase>()));
    return this;
  }
}
