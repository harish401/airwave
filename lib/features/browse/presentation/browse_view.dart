import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../catalog/presentation/controllers/catalog_controller.dart';
import '../../catalog/presentation/widgets/channel_card.dart';

class BrowseView extends ConsumerStatefulWidget {
  const BrowseView({super.key});

  @override
  ConsumerState<BrowseView> createState() => _BrowseViewState();
}

class _BrowseViewState extends ConsumerState<BrowseView> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  String _searchCountryQuery = '';
  String _searchLanguageQuery = '';
  String _searchBlockedQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoriesListProvider);
    final countries = ref.watch(countriesListProvider);
    final languages = ref.watch(languagesListProvider);
    final blocked = ref.watch(blockedChannelsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Browse Channels',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20),
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          indicatorColor: AppColors.liveRed,
          labelColor: AppColors.liveRed,
          unselectedLabelColor: AppColors.textSecondaryDark,
          tabs: const [
            Tab(text: 'Categories'),
            Tab(text: 'Countries'),
            Tab(text: 'Languages'),
            Tab(text: 'Blocked / Excluded'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Categories Tab
          _buildCategoriesGrid(categories),
          // Countries Tab
          _buildCountriesList(countries),
          // Languages Tab
          _buildLanguagesList(languages),
          // Blocked / Excluded Tab
          _buildBlockedList(blocked),
        ],
      ),
    );
  }

  Widget _buildCategoriesGrid(List categories) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final cat = categories[index];
        return InkWell(
          onTap: () => _openFilteredGrid(title: cat.name, categoryId: cat.id),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.darkCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.darkBorder),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    cat.name,
                    style: const TextStyle(
                      color: AppColors.textPrimaryDark,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ),
                const Icon(Icons.chevron_right, color: AppColors.neonCyan, size: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCountriesList(List countries) {
    final filtered = countries.where((c) {
      if (_searchCountryQuery.isEmpty) return true;
      final q = _searchCountryQuery.toLowerCase();
      return c.name.toLowerCase().contains(q) || c.code.toLowerCase().contains(q);
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            onChanged: (val) => setState(() => _searchCountryQuery = val),
            decoration: const InputDecoration(
              hintText: 'Search countries...',
              prefixIcon: Icon(Icons.search, color: AppColors.textSecondaryDark),
              isDense: true,
            ),
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: filtered.length,
            separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.darkBorder),
            itemBuilder: (context, index) {
              final c = filtered[index];
              return ListTile(
                leading: Text(c.flag, style: const TextStyle(fontSize: 24)),
                title: Text(c.name, style: const TextStyle(color: AppColors.textPrimaryDark)),
                subtitle: Text(c.code, style: const TextStyle(color: AppColors.textSecondaryDark)),
                trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondaryDark),
                onTap: () => _openFilteredGrid(title: '${c.flag} ${c.name}', countryCode: c.code),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLanguagesList(List languages) {
    final filtered = languages.where((l) {
      if (_searchLanguageQuery.isEmpty) return true;
      final q = _searchLanguageQuery.toLowerCase();
      return l.name.toLowerCase().contains(q) || l.code.toLowerCase().contains(q);
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            onChanged: (val) => setState(() => _searchLanguageQuery = val),
            decoration: const InputDecoration(
              hintText: 'Search languages (Tamil, Hindi, English...)...',
              prefixIcon: Icon(Icons.search, color: AppColors.textSecondaryDark),
              isDense: true,
            ),
          ),
        ),
        Expanded(
          child: filtered.isEmpty
              ? const Center(
                  child: Text(
                    'No matching languages found.',
                    style: TextStyle(color: AppColors.textSecondaryDark),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.darkBorder),
                  itemBuilder: (context, index) {
                    final lang = filtered[index];
                    return ListTile(
                      leading: const Icon(Icons.translate_rounded, color: AppColors.neonCyan),
                      title: Text(lang.name, style: const TextStyle(color: AppColors.textPrimaryDark, fontWeight: FontWeight.w600)),
                      subtitle: Text(lang.code, style: const TextStyle(color: AppColors.textSecondaryDark)),
                      trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondaryDark),
                      onTap: () => _openFilteredGrid(title: '${lang.name} Channels', langCode: lang.code),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildBlockedList(List blocked) {
    final filtered = blocked.where((b) {
      if (_searchBlockedQuery.isEmpty) return true;
      final q = _searchBlockedQuery.toLowerCase();
      return b.channel.toLowerCase().contains(q) || b.reason.toLowerCase().contains(q);
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            onChanged: (val) => setState(() => _searchBlockedQuery = val),
            decoration: const InputDecoration(
              hintText: 'Search blocked or excluded channels...',
              prefixIcon: Icon(Icons.search, color: AppColors.textSecondaryDark),
              isDense: true,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.darkCard,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.darkBorder),
          ),
          child: Row(
            children: [
              const Icon(Icons.shield_outlined, color: AppColors.liveRed, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'These ${blocked.length} channels are blocked or filtered by iptv-org due to DMCA, copyright notices, or adult restrictions.',
                  style: const TextStyle(color: AppColors.textSecondaryDark, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: filtered.isEmpty
              ? const Center(
                  child: Text(
                    'No blocked channels match search.',
                    style: TextStyle(color: AppColors.textSecondaryDark),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.darkBorder),
                  itemBuilder: (context, index) {
                    final item = filtered[index];
                    final isDmca = item.reason.toLowerCase().contains('dmca');
                    return ListTile(
                      leading: Icon(
                        isDmca ? Icons.gavel_rounded : Icons.block_rounded,
                        color: isDmca ? Colors.amber : AppColors.liveRed,
                      ),
                      title: Text(
                        item.channel,
                        style: const TextStyle(color: AppColors.textPrimaryDark, fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        'Reason: ${item.reason.toUpperCase()}',
                        style: TextStyle(
                          color: isDmca ? Colors.amber.shade300 : AppColors.liveRed,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.darkCard,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppColors.darkBorder),
                        ),
                        child: const Text(
                          'BLOCKED',
                          style: TextStyle(
                            color: AppColors.textSecondaryDark,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  void _openFilteredGrid({
    required String title,
    String? categoryId,
    String? countryCode,
    String? langCode,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _FilteredGridView(
          title: title,
          categoryId: categoryId,
          countryCode: countryCode,
          langCode: langCode,
        ),
      ),
    );
  }
}

class _FilteredGridView extends ConsumerWidget {
  final String title;
  final String? categoryId;
  final String? countryCode;
  final String? langCode;

  const _FilteredGridView({
    required this.title,
    this.categoryId,
    this.countryCode,
    this.langCode,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalog = ref.watch(filteredChannelsProvider);

    final matching = catalog.where((ch) {
      if (categoryId != null &&
          !ch.categories.any((c) => c.toLowerCase() == categoryId!.toLowerCase())) {
        return false;
      }
      if (countryCode != null &&
          ch.countryCode.toUpperCase() != countryCode!.toUpperCase()) {
        return false;
      }
      if (langCode != null &&
          !ch.languages.any((l) => l.toLowerCase() == langCode!.toLowerCase())) {
        return false;
      }
      return true;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: matching.isEmpty
          ? const Center(
              child: Text(
                'No channels found in this category.',
                style: TextStyle(color: AppColors.textSecondaryDark),
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.9,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: matching.length,
              itemBuilder: (context, index) {
                final channel = matching[index];
                return ChannelCard(
                  channel: channel,
                  onTap: () => context.push('/player/${channel.id}'),
                );
              },
            ),
    );
  }
}
