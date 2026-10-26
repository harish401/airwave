import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../catalog/presentation/controllers/catalog_controller.dart';
import '../../catalog/presentation/widgets/channel_card.dart';

class MyListView extends ConsumerStatefulWidget {
  const MyListView({super.key});

  @override
  ConsumerState<MyListView> createState() => _MyListViewState();
}

class _MyListViewState extends ConsumerState<MyListView> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final favoritesAsync = ref.watch(favoritesNotifierProvider);
    final historyAsync = ref.watch(historyNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Library',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.liveRed,
          labelColor: AppColors.liveRed,
          unselectedLabelColor: AppColors.textSecondaryDark,
          tabs: const [
            Tab(text: 'My List (Favorites)'),
            Tab(text: 'Watch History'),
          ],
        ),
        actions: [
          if (_tabController.index == 1)
            IconButton(
              icon: const Icon(Icons.delete_sweep_rounded, color: AppColors.textSecondaryDark),
              tooltip: 'Clear History',
              onPressed: () {
                ref.read(historyNotifierProvider.notifier).clearAll();
              },
            ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Favorites Tab
          favoritesAsync.when(
            data: (favs) {
              if (favs.isEmpty) {
                return _buildEmptyState(
                  icon: Icons.favorite_border_rounded,
                  title: 'Your list is empty',
                  subtitle: 'Save channels to your list to quickly watch them anytime.',
                );
              }
              return GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.9,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: favs.length,
                itemBuilder: (context, index) {
                  final ch = favs[index];
                  return Dismissible(
                    key: Key(ch.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      color: AppColors.liveRed,
                      child: const Icon(Icons.delete_rounded, color: Colors.white),
                    ),
                    onDismissed: (_) {
                      ref.read(favoritesNotifierProvider.notifier).toggleFavorite(ch.id);
                    },
                    child: ChannelCard(
                      channel: ch,
                      onTap: () => context.push('/player/${ch.id}'),
                    ),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator(color: AppColors.liveRed)),
            error: (e, _) => Center(child: Text('Error: $e')),
          ),
          // History Tab
          historyAsync.when(
            data: (hist) {
              if (hist.isEmpty) {
                return _buildEmptyState(
                  icon: Icons.history_rounded,
                  title: 'No watch history yet',
                  subtitle: 'Channels you play will appear here for fast resuming.',
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: hist.length,
                separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.darkBorder),
                itemBuilder: (context, index) {
                  final ch = hist[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: AppColors.darkSurface,
                      child: Text(
                        ch.initials,
                        style: const TextStyle(
                          color: AppColors.neonCyan,
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    title: Text(ch.name, style: const TextStyle(color: AppColors.textPrimaryDark)),
                    subtitle: Text(
                      ch.categories.join(' • '),
                      style: const TextStyle(color: AppColors.textSecondaryDark, fontSize: 12),
                    ),
                    trailing: const Icon(Icons.play_arrow_rounded, color: AppColors.liveRed),
                    onTap: () => context.push('/player/${ch.id}'),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator(color: AppColors.liveRed)),
            error: (e, _) => Center(child: Text('Error: $e')),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: AppColors.textTertiaryDark),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimaryDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: AppColors.textSecondaryDark),
            ),
          ],
        ),
      ),
    );
  }
}
