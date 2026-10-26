import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/models/filter_state.dart';
import '../controllers/catalog_controller.dart';

class FilterBottomSheet extends ConsumerStatefulWidget {
  const FilterBottomSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const FilterBottomSheet(),
    );
  }

  @override
  ConsumerState<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends ConsumerState<FilterBottomSheet> {
  String _countrySearch = '';

  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(filterNotifierProvider);
    final filterNotifier = ref.read(filterNotifierProvider.notifier);
    final categories = ref.watch(categoriesListProvider);
    final countries = ref.watch(countriesListProvider);

    final filteredCountries = countries.where((c) {
      if (_countrySearch.isEmpty) return true;
      final q = _countrySearch.toLowerCase();
      return c.name.toLowerCase().contains(q) || c.code.toLowerCase().contains(q);
    }).toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Text(
                      'Filters',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimaryDark,
                      ),
                    ),
                    if (filter.hasActiveFilters) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.liveRed,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${filter.activeFiltersCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                Row(
                  children: [
                    if (filter.hasActiveFilters)
                      TextButton(
                        onPressed: filterNotifier.reset,
                        child: const Text('Reset', style: TextStyle(color: AppColors.neonCyan)),
                      ),
                    IconButton(
                      icon: const Icon(Icons.close, color: AppColors.textSecondaryDark),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.darkBorder),
          // Scrollable Options
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // View Mode
                _buildSectionTitle('View Mode'),
                Wrap(
                  spacing: 8,
                  children: ViewMode.values.map((mode) {
                    final isSelected = filter.viewMode == mode;
                    return ChoiceChip(
                      label: Text(mode.label),
                      selected: isSelected,
                      onSelected: (_) => filterNotifier.setViewMode(mode),
                      selectedColor: AppColors.liveRed,
                      backgroundColor: AppColors.darkSurface,
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),

                // Sort By
                _buildSectionTitle('Sort By'),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: SortOption.values.map((option) {
                    final isSelected = filter.sortBy == option;
                    return ChoiceChip(
                      label: Text(option.label),
                      selected: isSelected,
                      onSelected: (_) => filterNotifier.setSortOption(option),
                      selectedColor: AppColors.liveRed,
                      backgroundColor: AppColors.darkSurface,
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),

                // Minimum Quality
                _buildSectionTitle('Minimum Stream Quality'),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: MinQualityFilter.values.map((q) {
                    final isSelected = filter.minQuality == q;
                    return ChoiceChip(
                      label: Text(q.label),
                      selected: isSelected,
                      onSelected: (_) => filterNotifier.setMinQuality(q),
                      selectedColor: AppColors.neonCyan.withOpacity(0.3),
                      backgroundColor: AppColors.darkSurface,
                      labelStyle: TextStyle(
                        color: isSelected ? AppColors.neonCyan : AppColors.textPrimaryDark,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),

                // Flags & Toggles
                _buildSectionTitle('Stream Availability'),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Hide Geo-Blocked Streams',
                      style: TextStyle(color: AppColors.textPrimaryDark, fontSize: 14)),
                  subtitle: const Text('Only show streams without region restrictions',
                      style: TextStyle(color: AppColors.textSecondaryDark, fontSize: 12)),
                  value: filter.hideGeoBlocked,
                  activeColor: AppColors.liveRed,
                  onChanged: (_) => filterNotifier.toggleHideGeoBlocked(),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('24/7 Channels Only',
                      style: TextStyle(color: AppColors.textPrimaryDark, fontSize: 14)),
                  subtitle: const Text('Hide channels labeled as intermittent or not 24/7',
                      style: TextStyle(color: AppColors.textSecondaryDark, fontSize: 12)),
                  value: filter.only247,
                  activeColor: AppColors.liveRed,
                  onChanged: (_) => filterNotifier.toggleOnly247(),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Only Channels with Logo',
                      style: TextStyle(color: AppColors.textPrimaryDark, fontSize: 14)),
                  value: filter.onlyWithLogo,
                  activeColor: AppColors.liveRed,
                  onChanged: (_) => filterNotifier.toggleOnlyWithLogo(),
                ),
                const SizedBox(height: 20),

                // Categories Multi-Select
                _buildSectionTitle('Categories (${filter.selectedCategories.length} selected)'),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: categories.take(24).map((cat) {
                    final isSelected = filter.selectedCategories.contains(cat.id.toLowerCase());
                    return FilterChip(
                      label: Text(cat.name),
                      selected: isSelected,
                      onSelected: (_) => filterNotifier.toggleCategory(cat.id),
                      selectedColor: AppColors.liveRed.withOpacity(0.3),
                      backgroundColor: AppColors.darkSurface,
                      checkmarkColor: AppColors.liveRed,
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),

                // Countries Multi-Select with Search
                _buildSectionTitle('Countries (${filter.selectedCountries.length} selected)'),
                TextField(
                  onChanged: (val) => setState(() => _countrySearch = val),
                  decoration: const InputDecoration(
                    hintText: 'Search countries...',
                    prefixIcon: Icon(Icons.search, size: 20, color: AppColors.textSecondaryDark),
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: filteredCountries.take(20).map((country) {
                    final isSelected =
                        filter.selectedCountries.contains(country.code.toUpperCase());
                    return FilterChip(
                      label: Text('${country.flag} ${country.name}'),
                      selected: isSelected,
                      onSelected: (_) => filterNotifier.toggleCountry(country.code),
                      selectedColor: AppColors.liveRed.withOpacity(0.3),
                      backgroundColor: AppColors.darkSurface,
                      checkmarkColor: AppColors.liveRed,
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          // Apply Button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: AppColors.cinemaBlack,
              border: Border(top: BorderSide(color: AppColors.darkBorder)),
            ),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.liveRed,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text(
                  'Apply Filters',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: AppColors.neonCyan,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
