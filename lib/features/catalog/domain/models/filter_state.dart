enum SortOption {
  relevance('Relevance'),
  az('A to Z'),
  za('Z to A'),
  quality('Quality (HD/FHD)'),
  recentlyLaunched('Recently Launched');

  final String label;
  const SortOption(this.label);
}

enum ViewMode {
  grid('Grid'),
  list('List'),
  compact('Compact');

  final String label;
  const ViewMode(this.label);
}

enum MinQualityFilter {
  any('Any Quality', 0),
  sd('SD (360p+)', 360),
  p480('480p+', 480),
  p720('720p+ (HD)', 720),
  p1080('1080p+ (FHD)', 1080);

  final String label;
  final int minHeight;
  const MinQualityFilter(this.label, this.minHeight);
}

class FilterState {
  final Set<String> selectedCountries;
  final Set<String> selectedCategories;
  final Set<String> selectedLanguages;
  final MinQualityFilter minQuality;
  final bool hideGeoBlocked;
  final bool only247;
  final bool onlyWithLogo;
  final SortOption sortBy;
  final ViewMode viewMode;
  final String searchQuery;

  const FilterState({
    this.selectedCountries = const {},
    this.selectedCategories = const {},
    this.selectedLanguages = const {},
    this.minQuality = MinQualityFilter.any,
    this.hideGeoBlocked = false,
    this.only247 = false,
    this.onlyWithLogo = false,
    this.sortBy = SortOption.relevance,
    this.viewMode = ViewMode.grid,
    this.searchQuery = '',
  });

  int get activeFiltersCount {
    int count = 0;
    if (selectedCountries.isNotEmpty) count += selectedCountries.length;
    if (selectedCategories.isNotEmpty) count += selectedCategories.length;
    if (selectedLanguages.isNotEmpty) count += selectedLanguages.length;
    if (minQuality != MinQualityFilter.any) count += 1;
    if (hideGeoBlocked) count += 1;
    if (only247) count += 1;
    if (onlyWithLogo) count += 1;
    if (sortBy != SortOption.relevance) count += 1;
    return count;
  }

  bool get hasActiveFilters => activeFiltersCount > 0;

  FilterState copyWith({
    Set<String>? selectedCountries,
    Set<String>? selectedCategories,
    Set<String>? selectedLanguages,
    MinQualityFilter? minQuality,
    bool? hideGeoBlocked,
    bool? only247,
    bool? onlyWithLogo,
    SortOption? sortBy,
    ViewMode? viewMode,
    String? searchQuery,
  }) {
    return FilterState(
      selectedCountries: selectedCountries ?? this.selectedCountries,
      selectedCategories: selectedCategories ?? this.selectedCategories,
      selectedLanguages: selectedLanguages ?? this.selectedLanguages,
      minQuality: minQuality ?? this.minQuality,
      hideGeoBlocked: hideGeoBlocked ?? this.hideGeoBlocked,
      only247: only247 ?? this.only247,
      onlyWithLogo: onlyWithLogo ?? this.onlyWithLogo,
      sortBy: sortBy ?? this.sortBy,
      viewMode: viewMode ?? this.viewMode,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  FilterState reset() => const FilterState();
}
