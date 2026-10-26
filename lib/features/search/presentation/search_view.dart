import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../catalog/domain/models/channel.dart';
import '../../catalog/presentation/controllers/catalog_controller.dart';
import '../../catalog/presentation/widgets/channel_card.dart';
import '../../catalog/presentation/widgets/filter_bottom_sheet.dart';

class SearchView extends ConsumerStatefulWidget {
  const SearchView({super.key});

  @override
  ConsumerState<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends ConsumerState<SearchView> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;
  List<Channel> _searchResults = [];
  bool _isSearching = false;
  final List<String> _recentSearches = ['BBC', 'CNN', 'Sports', 'Sky', 'News', 'Discovery'];

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);
    _debounceTimer = Timer(const Duration(milliseconds: 300), () async {
      final repo = ref.read(catalogRepositoryProvider);
      final results = await repo.searchInstant(query);
      if (mounted) {
        setState(() {
          _searchResults = results;
          _isSearching = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(filterNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: false,
          onChanged: _onSearchChanged,
          style: const TextStyle(color: AppColors.textPrimaryDark),
          decoration: InputDecoration(
            hintText: 'Search channel, network, alt names...',
            prefixIcon: const Icon(Icons.search, color: AppColors.neonCyan),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, color: AppColors.textSecondaryDark),
                    onPressed: () {
                      _searchController.clear();
                      _onSearchChanged('');
                    },
                  )
                : null,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          ),
        ),
        actions: [
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
                      style: const TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isSearching) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.liveRed),
      );
    }

    if (_searchController.text.isNotEmpty) {
      if (_searchResults.isEmpty) {
        return const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.search_off_rounded, size: 48, color: AppColors.textSecondaryDark),
              SizedBox(height: 12),
              Text(
                'No live channels match your search.',
                style: TextStyle(color: AppColors.textSecondaryDark, fontSize: 16),
              ),
            ],
          ),
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
        itemCount: _searchResults.length,
        itemBuilder: (context, index) {
          final ch = _searchResults[index];
          return ChannelCard(
            channel: ch,
            onTap: () => context.push('/player/${ch.id}'),
          );
        },
      );
    }

    // Default State: Recent Searches & Suggestions
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'Popular Suggestions',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.neonCyan,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _recentSearches.map((tag) {
            return ActionChip(
              label: Text(tag),
              backgroundColor: AppColors.darkCard,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: AppColors.darkBorder),
              ),
              onPressed: () {
                _searchController.text = tag;
                _onSearchChanged(tag);
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}
