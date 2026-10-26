import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../catalog/domain/models/channel.dart';
import '../../catalog/presentation/controllers/catalog_controller.dart';
import '../../catalog/presentation/widgets/channel_details_sheet.dart';
import '../../catalog/presentation/widgets/channel_row.dart';
import '../../catalog/presentation/widgets/filter_bottom_sheet.dart';
import '../../catalog/presentation/widgets/hero_carousel.dart';
import '../../catalog/presentation/widgets/shimmer_loading.dart';

class HomeView extends ConsumerWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalogAsync = ref.watch(catalogNotifierProvider);
    final featuredChannels = ref.watch(featuredChannelsProvider);
    final allChannels = ref.watch(filteredChannelsProvider);
    final favorites = ref.watch(favoritesNotifierProvider).value ?? [];
    final history = ref.watch(historyNotifierProvider).value ?? [];
    final filter = ref.watch(filterNotifierProvider);
    final filterNotifier = ref.read(filterNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.liveRed,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.waves_rounded, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            const Text(
              'AIRWAVE',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
                fontSize: 20,
                color: AppColors.textPrimaryDark,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded, color: AppColors.textPrimaryDark),
            onPressed: () => context.go('/search'),
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.tune_rounded, color: AppColors.neonCyan),
                onPressed: () => FilterBottomSheet.show(context),
              ),
              if (filter.hasActiveFilters)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.liveRed,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${filter.activeFiltersCount}',
                      style: const TextStyle(
                        fontSize: 9,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: catalogAsync.when(
        data: (catalog) {
          if (catalog.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.cloud_off_rounded, size: 64, color: AppColors.textTertiaryDark),
                  const SizedBox(height: 16),
                  const Text(
                    'No live channels found',
                    style: TextStyle(fontSize: 18, color: AppColors.textPrimaryDark),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => ref.read(catalogNotifierProvider.notifier).refresh(),
                    child: const Text('Retry Fetch'),
                  ),
                ],
              ),
            );
          }

          // Segregated rows
          final newsChannels = _filterByCat(allChannels, 'news');
          final sportsChannels = _filterByCat(allChannels, 'sports');
          final movieChannels = _filterByCat(allChannels, 'movies');
          final musicChannels = _filterByCat(allChannels, 'music');
          final kidsChannels = _filterByCat(allChannels, 'kids');
          final docChannels = _filterByCat(allChannels, 'documentary');

          // Language rows
          final englishChannels = _filterByLang(allChannels, 'eng');
          final regionalChannels = allChannels
              .where((c) => c.languages.any((l) => l == 'tam' || l == 'hin' || l == 'tel'))
              .take(15)
              .toList();

          return RefreshIndicator(
            color: AppColors.liveRed,
            backgroundColor: AppColors.darkCard,
            onRefresh: () => ref.read(catalogNotifierProvider.notifier).refresh(),
            child: ListView(
              padding: const EdgeInsets.only(bottom: 32),
              children: [
                // Active Filters Chip Strip
                if (filter.hasActiveFilters)
                  _buildActiveFiltersStrip(context, filter, filterNotifier),

                // Hero Carousel (if not filtered down to 0)
                if (featuredChannels.isNotEmpty && !filter.hasActiveFilters)
                  HeroCarousel(
                    channels: featuredChannels,
                    onWatchLive: (ch) => context.push('/player/${ch.id}'),
                    onDetails: (ch) => ChannelDetailsSheet.show(
                      context,
                      ch,
                      (c) => context.push('/player/${c.id}'),
                    ),
                  ),

                // Continue Watching
                if (history.isNotEmpty)
                  ChannelRow(
                    title: 'Continue Watching',
                    subtitle: 'Jump back to your recently watched streams',
                    channels: history,
                    onChannelTap: (ch) => context.push('/player/${ch.id}'),
                    onSeeAll: () => context.go('/my-list'),
                  ),

                // My List (Favorites)
                if (favorites.isNotEmpty)
                  ChannelRow(
                    title: 'My List',
                    subtitle: 'Channels you have favorited',
                    channels: favorites,
                    onChannelTap: (ch) => context.push('/player/${ch.id}'),
                    onSeeAll: () => context.go('/my-list'),
                  ),

                // Popular Worldwide
                ChannelRow(
                  title: 'Popular Worldwide',
                  subtitle: 'Top quality verified 24/7 channels',
                  channels: allChannels.take(15).toList(),
                  onChannelTap: (ch) => context.push('/player/${ch.id}'),
                ),

                // Live News
                if (newsChannels.isNotEmpty)
                  ChannelRow(
                    title: 'Live News',
                    subtitle: 'Breaking headlines and global coverage',
                    channels: newsChannels,
                    onChannelTap: (ch) => context.push('/player/${ch.id}'),
                  ),

                // Sports & Action
                if (sportsChannels.isNotEmpty)
                  ChannelRow(
                    title: 'Sports & Competition',
                    channels: sportsChannels,
                    onChannelTap: (ch) => context.push('/player/${ch.id}'),
                  ),

                // Movies & Entertainment
                if (movieChannels.isNotEmpty)
                  ChannelRow(
                    title: 'Movies & Series',
                    channels: movieChannels,
                    onChannelTap: (ch) => context.push('/player/${ch.id}'),
                  ),

                // Regional Indian / Asian Streams (Tamil, Hindi, Telugu)
                if (regionalChannels.isNotEmpty)
                  ChannelRow(
                    title: 'Regional Favorites',
                    subtitle: 'Popular regional language broadcasts',
                    channels: regionalChannels,
                    onChannelTap: (ch) => context.push('/player/${ch.id}'),
                  ),

                // Music & Beats
                if (musicChannels.isNotEmpty)
                  ChannelRow(
                    title: 'Music & Radio TV',
                    channels: musicChannels,
                    onChannelTap: (ch) => context.push('/player/${ch.id}'),
                  ),

                // Kids & Animation
                if (kidsChannels.isNotEmpty)
                  ChannelRow(
                    title: 'Kids & Cartoons',
                    channels: kidsChannels,
                    onChannelTap: (ch) => context.push('/player/${ch.id}'),
                  ),

                // Documentaries
                if (docChannels.isNotEmpty)
                  ChannelRow(
                    title: 'Documentary & Nature',
                    channels: docChannels,
                    onChannelTap: (ch) => context.push('/player/${ch.id}'),
                  ),

                // English World
                if (englishChannels.isNotEmpty)
                  ChannelRow(
                    title: 'English Broadcasts',
                    channels: englishChannels,
                    onChannelTap: (ch) => context.push('/player/${ch.id}'),
                  ),
              ],
            ),
          );
        },
        loading: () => const CatalogLoadingSkeleton(),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline_rounded, size: 60, color: AppColors.liveRed),
                const SizedBox(height: 16),
                Text(
                  'Failed to load live catalog: $err',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.textSecondaryDark),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.read(catalogNotifierProvider.notifier).refresh(),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.liveRed),
                  child: const Text('Try Again'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActiveFiltersStrip(
    BuildContext context,
    dynamic filter,
    dynamic filterNotifier,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: AppColors.darkCard,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            ActionChip(
              avatar: const Icon(Icons.clear_all_rounded, size: 16, color: AppColors.liveRed),
              label: const Text('Clear All'),
              onPressed: filterNotifier.reset,
            ),
            const SizedBox(width: 8),
            ...filter.selectedCountries.map((c) => Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: InputChip(
                    label: Text('Country: $c'),
                    onDeleted: () => filterNotifier.toggleCountry(c),
                  ),
                )),
            ...filter.selectedCategories.map((cat) => Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: InputChip(
                    label: Text('Category: $cat'),
                    onDeleted: () => filterNotifier.toggleCategory(cat),
                  ),
                )),
          ],
        ),
      ),
    );
  }

  List<Channel> _filterByCat(List<Channel> channels, String cat) {
    final lower = cat.toLowerCase();
    return channels
        .where((c) => c.categories.any((element) => element.toLowerCase().contains(lower)))
        .take(15)
        .toList();
  }

  List<Channel> _filterByLang(List<Channel> channels, String lang) {
    final lower = lang.toLowerCase();
    return channels
        .where((c) => c.languages.any((l) => l.toLowerCase() == lower))
        .take(15)
        .toList();
  }
}
