import 'package:android_cache_cleaner/core/di/injection.dart';
import 'package:android_cache_cleaner/l10n/generated/app_localizations.dart';
import 'package:android_cache_cleaner/presentation/bloc/cleaning/cleaning_bloc.dart';
import 'package:android_cache_cleaner/presentation/bloc/cleaning/cleaning_event.dart';
import 'package:android_cache_cleaner/presentation/bloc/cleaning/cleaning_state.dart';
import 'package:android_cache_cleaner/presentation/bloc/storage/storage_bloc.dart';
import 'package:android_cache_cleaner/presentation/bloc/storage/storage_event.dart';
import 'package:android_cache_cleaner/presentation/bloc/storage/storage_state.dart';
import 'package:android_cache_cleaner/presentation/pages/about_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => getIt<StorageBloc>()..add(FetchStorageStats()),
        ),
        BlocProvider(create: (context) => getIt<CleaningBloc>()),
      ],
      child: const DashboardView(),
    );
  }
}

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Refresh the stats when returning to the app (e.g. after accessibility service finishes)
      if (context.mounted) {
        context.read<StorageBloc>().add(FetchStorageStats());
      }
    }
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1048576) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1073741824) return '${(bytes / 1048576).toStringAsFixed(1)} MB';
    return '${(bytes / 1073741824).toStringAsFixed(2)} GB';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: l10n.info,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AboutPage()),
              );
            },
          ),
        ],
      ),
      body: BlocListener<CleaningBloc, CleaningState>(
        listener: (context, state) {
          if (state is CleaningSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.cacheCleaningCompleted)),
            );
            context.read<StorageBloc>().add(FetchStorageStats());
          } else if (state is AccessibilityPermissionRequired) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(l10n.accessibilityRequired)));
          } else if (state is CleaningError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.errorMessage(state.message))),
            );
          }
        },
        child: BlocBuilder<StorageBloc, StorageState>(
          builder: (context, state) {
            if (state is StorageLoading || state is StorageInitial) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is StorageError) {
              return Center(child: Text(l10n.errorMessage(state.message)));
            } else if (state is StorageLoaded) {
              final apps = state.apps;
              if (apps.isEmpty) {
                return Center(child: Text(l10n.noAppsFound));
              }

              final topOffenders = apps.take(3).toList();

              return RefreshIndicator(
                onRefresh: () async {
                  context.read<StorageBloc>().add(FetchStorageStats());
                  // On attend que le bloc passe en état de succès ou erreur avant de terminer l'animation
                  await context.read<StorageBloc>().stream.firstWhere(
                    (s) => s is StorageLoaded || s is StorageError,
                  );
                },
                child: CustomScrollView(
                  physics:
                      const AlwaysScrollableScrollPhysics(), // Important pour que le pull-to-refresh marche même si la liste est courte
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Card(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.totalCacheSize,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _formatBytes(state.totalCacheSize),
                                  style: Theme.of(context)
                                      .textTheme
                                      .displayMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onPrimaryContainer,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8.0,
                        ),
                        child: Text(
                          l10n.topOffenders,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: 150,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          itemCount: topOffenders.length,
                          itemBuilder: (context, index) {
                            final app = topOffenders[index];
                            return Container(
                              width: 140,
                              margin: const EdgeInsets.symmetric(
                                horizontal: 8.0,
                              ),
                              child: Card(
                                color: Theme.of(
                                  context,
                                ).colorScheme.secondaryContainer,
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      if (app.iconBytes != null)
                                        Image.memory(
                                          app.iconBytes!,
                                          width: 32,
                                          height: 32,
                                        )
                                      else
                                        const Icon(Icons.android, size: 32),
                                      const SizedBox(height: 8),
                                      Text(
                                        app.appName,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(
                                          context,
                                        ).textTheme.titleSmall,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _formatBytes(app.cacheSize),
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.error,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          l10n.allApplications,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                    ),
                    SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final app = apps[index];
                        return ListTile(
                          leading: app.iconBytes != null
                              ? Image.memory(
                                  app.iconBytes!,
                                  width: 40,
                                  height: 40,
                                )
                              : CircleAvatar(
                                  backgroundColor: Theme.of(
                                    context,
                                  ).colorScheme.surfaceContainerHighest,
                                  child: const Icon(Icons.android),
                                ),
                          title: Text(app.appName),
                          subtitle: Text(
                            l10n.appSize(_formatBytes(app.totalSize)),
                          ),
                          trailing: Text(
                            _formatBytes(app.cacheSize),
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.error,
                                ),
                          ),
                        );
                      }, childCount: apps.length),
                    ),
                    // Bottom padding for FAB
                    const SliverToBoxAdapter(child: SizedBox(height: 80)),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
      floatingActionButton: BlocBuilder<StorageBloc, StorageState>(
        builder: (context, state) {
          if (state is StorageLoaded && state.apps.isNotEmpty) {
            return FloatingActionButton.extended(
              onPressed: () {
                final targetPackages = state.apps
                    .where((app) => app.cacheSize > 0)
                    .map((app) => app.packageName)
                    .toList();
                context.read<CleaningBloc>().add(StartCleaning(targetPackages));
              },
              icon: const Icon(Icons.cleaning_services),
              label: Text(l10n.cleanAllCache),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
