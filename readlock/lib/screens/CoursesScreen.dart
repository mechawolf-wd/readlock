// Courses list screen showing available courses
// Clean card-based layout with course selection

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:readlock/utility_widgets/Utility.dart';
import 'package:readlock/utility_widgets/SelectableFilterChips.dart';
import 'package:readlock/utility_widgets/BookListCard.dart';
import 'package:readlock/utility_widgets/RLCard.dart';
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/constants/RLDesignSystem.dart';
import 'package:readlock/constants/RLUIStrings.dart';
import 'package:readlock/constants/DartAliases.dart';

class CoursesScreen extends StatefulWidget {
  const CoursesScreen({super.key});

  @override
  State<CoursesScreen> createState() => CoursesScreenState();
}

class CoursesScreenState extends State<CoursesScreen> {
  bool isSearchActive = false;
  String? selectedGenre;
  int displayedItemsCount = 7;
  final int itemsPerLoad = 7;
  final TextEditingController searchController = TextEditingController();
  final FocusNode searchFocusNode = FocusNode();

  @override
  void dispose() {
    searchController.dispose();
    searchFocusNode.dispose();
    super.dispose();
  }

  void activateSearch() {
    setState(() {
      isSearchActive = true;
      selectedGenre = null;
      displayedItemsCount = 7;
    });
    searchFocusNode.requestFocus();
  }

  void handleSearchTextChanged(String searchText) {
    setState(() {});
  }

  void deactivateSearch() {
    setState(() {
      isSearchActive = false;
      displayedItemsCount = 7;
      searchController.clear();
    });
    searchFocusNode.unfocus();
  }

  void selectGenre(String genre) {
    setState(() {
      selectedGenre = genre;
      isSearchActive = false;
      displayedItemsCount = 7;
      searchController.clear();
    });
    searchFocusNode.unfocus();
  }

  void clearGenreSelection() {
    setState(() {
      selectedGenre = null;
      displayedItemsCount = 7;
    });
  }

  void loadMoreResults() {
    setState(() {
      displayedItemsCount += itemsPerLoad;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool hasSearchText = searchController.text.isNotEmpty;
    final bool shouldShowSearchResults = hasSearchText || selectedGenre != null;
    final bool isGenreSelected = selectedGenre != null;
    final bool shouldShowSearchBar = !isGenreSelected;
    final bool shouldShowCategories = !hasSearchText;

    return Scaffold(
      backgroundColor: RLDS.backgroundDark,
      body: SafeArea(
        bottom: false,
        child: RenderIf.condition(
          shouldShowSearchResults,
          SearchResultsLayout(
            shouldShowSearchBar: shouldShowSearchBar,
            shouldShowCategories: shouldShowCategories,
          ),
          DefaultLayout(
            shouldShowSearchBar: shouldShowSearchBar,
            shouldShowCategories: shouldShowCategories,
          ),
        ),
      ),
    );
  }

  Widget DefaultLayout({
    required bool shouldShowSearchBar,
    required bool shouldShowCategories,
  }) {
    return SingleChildScrollView(
      child: Div.column([
        // Main content (with padding)
        Padding(
          padding: const EdgeInsets.all(RLDS.spacing24),
          child: Div.column([
            // Search bar (hidden when genre is selected)
            RenderIf.condition(
              shouldShowSearchBar,
              Div.column([
                MockSearchBar(),

                const Spacing.height(24),
              ], crossAxisAlignment: CrossAxisAlignment.stretch),
              const SizedBox.shrink(),
            ),

            // Categories (visible unless searching)
            RenderIf.condition(
              shouldShowCategories,
              Div.column([
                CategoriesSection(),

                const Spacing.height(32),
              ], crossAxisAlignment: CrossAxisAlignment.stretch),
              const SizedBox.shrink(),
            ),

            // Trending section
            TrendingSection(),
          ], crossAxisAlignment: CrossAxisAlignment.stretch),
        ),
      ], crossAxisAlignment: CrossAxisAlignment.stretch),
    );
  }

  Widget SearchResultsLayout({
    required bool shouldShowSearchBar,
    required bool shouldShowCategories,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Fixed header content (with padding)
        Padding(
          padding: const EdgeInsets.fromLTRB(
            RLDS.spacing24,
            RLDS.spacing24,
            RLDS.spacing24,
            0,
          ),
          child: Div.column([
            // Search bar (hidden when genre is selected)
            RenderIf.condition(
              shouldShowSearchBar,
              Div.column([
                MockSearchBar(),

                const Spacing.height(24),
              ], crossAxisAlignment: CrossAxisAlignment.stretch),
              const SizedBox.shrink(),
            ),

            // Categories (visible unless typing in search)
            RenderIf.condition(
              shouldShowCategories,
              Div.column([
                CategoriesSection(),

                const Spacing.height(24),
              ], crossAxisAlignment: CrossAxisAlignment.stretch),
              const SizedBox.shrink(),
            ),
          ], crossAxisAlignment: CrossAxisAlignment.stretch),
        ),

        // Expanded search results (scrollable)
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: RLDS.spacing24),
            child: SearchResults(),
          ),
        ),
      ],
    );
  }

  Widget MockSearchBar() {
    final BoxDecoration searchBarDecoration = BoxDecoration(
      color: RLDS.backgroundLight.withValues(alpha: 0.1),
      borderRadius: RLDS.borderRadiusSmall,
      border: Border.all(color: RLDS.textMuted.withValues(alpha: 0.3)),
    );

    final Widget SearchIcon = const Icon(
      Icons.search,
      color: RLDS.textSecondary,
      size: RLDS.iconMedium,
    );

    return RenderIf.condition(
      isSearchActive,
      ActiveSearchBar(searchBarDecoration: searchBarDecoration, searchIcon: SearchIcon),
      InactiveSearchBar(searchBarDecoration: searchBarDecoration, searchIcon: SearchIcon),
    );
  }

  Widget InactiveSearchBar({
    required BoxDecoration searchBarDecoration,
    required Widget searchIcon,
  }) {
    return GestureDetector(
      onTap: activateSearch,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: RLDS.spacing16,
          vertical: RLDS.spacing12,
        ),
        decoration: searchBarDecoration,
        child: Div.row([
          searchIcon,

          const Spacing.width(12),

          Text(
            RLUIStrings.SEARCH_PLACEHOLDER,
            style: RLTypography.bodyMediumStyle.copyWith(color: RLDS.textSecondary),
          ),
        ]),
      ),
    );
  }

  Widget ActiveSearchBar({
    required BoxDecoration searchBarDecoration,
    required Widget searchIcon,
  }) {
    final Widget CloseIcon = const Icon(
      Icons.close,
      color: RLDS.textSecondary,
      size: RLDS.iconMedium,
    );

    final bool hasSearchText = searchController.text.isNotEmpty;

    final Color borderColor = hasSearchText
        ? RLDS.info
        : RLDS.textMuted.withValues(alpha: 0.3);

    final double borderWidth = hasSearchText ? 1.5 : 1;

    final BoxDecoration activeSearchBarDecoration = BoxDecoration(
      color: RLDS.backgroundLight.withValues(alpha: 0.08),
      borderRadius: RLDS.borderRadiusSmall,
      border: Border.all(color: borderColor, width: borderWidth),
    );

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(
        horizontal: RLDS.spacing16,
        vertical: RLDS.spacing12,
      ),
      decoration: activeSearchBarDecoration,
      child: Div.row([
        searchIcon,

        const Spacing.width(12),

        Expanded(
          child: TextField(
            controller: searchController,
            focusNode: searchFocusNode,
            style: RLTypography.bodyMediumStyle,
            decoration: InputDecoration(
              hintText: RLUIStrings.SEARCH_PLACEHOLDER,
              hintStyle: RLTypography.bodyMediumStyle.copyWith(color: RLDS.textSecondary),
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
            onChanged: handleSearchTextChanged,
          ),
        ),

        const Spacing.width(12),

        GestureDetector(onTap: deactivateSearch, child: CloseIcon),
      ]),
    );
  }

  Widget CategoriesSection() {
    final List<String> categories = [
      'Design',
      'Psychology',
      'Business',
      'Technology',
      'Self-Help',
      'Fiction',
      'Science',
      'History',
    ];

    return Div.column([
      Div.row([
        Text(
          RLUIStrings.GENRES_LABEL,
          style: RLTypography.bodyMediumStyle.copyWith(color: RLDS.textSecondary),
        ),
      ], mainAxisAlignment: MainAxisAlignment.start),

      const Spacing.height(12),

      SelectableFilterChips(
        options: categories,
        selectedOption: selectedGenre,
        onChanged: handleGenreChipTap,
      ),
    ], crossAxisAlignment: CrossAxisAlignment.start);
  }

  void handleGenreChipTap(String category) {
    HapticFeedback.lightImpact();

    final bool isAlreadySelected = selectedGenre == category;

    if (isAlreadySelected) {
      clearGenreSelection();
    } else {
      selectGenre(category);
    }
  }

  Widget TrendingHeader() {
    return Div.column([
      Div.row([
        RLTypography.headingMedium(RLUIStrings.OTHERS_READING_TITLE),
      ], mainAxisAlignment: MainAxisAlignment.start),

      const Spacing.height(4),

      Div.row([
        Text(
          RLUIStrings.OTHERS_READING_SUBTITLE,
          style: RLTypography.bodyMediumStyle.copyWith(color: RLDS.textSecondary),
        ),
      ], mainAxisAlignment: MainAxisAlignment.start),
    ], crossAxisAlignment: CrossAxisAlignment.start);
  }

  Widget TrendingBooksList() {
    final JSONList trendingBooks = [
      {
        'title': 'Design of Everyday Things',
        'author': 'Don Norman',
        'progress': 0.65,
        'coverImage': 'assets/covers/doet-cover.png',
      },
      {'title': 'Atomic Habits', 'author': 'James Clear', 'progress': 0.40, 'coverImage': null},
      {'title': 'Deep Work', 'author': 'Cal Newport', 'progress': 0.85, 'coverImage': null},
      {
        'title': 'Thinking, Fast and Slow',
        'author': 'Daniel Kahneman',
        'progress': 0.22,
        'coverImage': null,
      },
      {'title': 'Hooked', 'author': 'Nir Eyal', 'progress': 0.55, 'coverImage': null},
    ];

    return Div.column(
      TrendingBookCards(trendingBooks),
      crossAxisAlignment: CrossAxisAlignment.start,
    );
  }

  List<Widget> TrendingBookCards(JSONList books) {
    return books.map((book) {
      final String bookTitle = book['title'] ?? '';
      final String bookAuthor = book['author'] ?? '';
      final String? coverImagePath = book['coverImage'];

      return BookListCard(
        title: bookTitle,
        author: bookAuthor,
        coverImagePath: coverImagePath,
      );
    }).toList();
  }

  Widget TrendingSection() {
    return Div.column([
      // Trending section
      TrendingHeader(),

      const Spacing.height(16),

      // Books list
      TrendingBooksList(),
    ], crossAxisAlignment: CrossAxisAlignment.stretch);
  }

  Widget SearchResults() {
    final JSONList allSearchResults = [
      {
        'title': 'The Design of Everyday Things',
        'author': 'Don Norman',
        'coverImage': 'assets/covers/doet-cover.png',
        'category': 'Design',
      },
      {
        'title': 'Thinking, Fast and Slow',
        'author': 'Daniel Kahneman',
        'coverImage': null,
        'category': 'Psychology',
      },
      {
        'title': 'The Lean Startup',
        'author': 'Eric Ries',
        'coverImage': null,
        'category': 'Business',
      },
      {'title': 'Hooked', 'author': 'Nir Eyal', 'coverImage': null, 'category': 'Design'},
      {
        'title': 'Clean Code',
        'author': 'Robert C. Martin',
        'coverImage': null,
        'category': 'Technology',
      },
      {
        'title': 'Atomic Habits',
        'author': 'James Clear',
        'coverImage': null,
        'category': 'Self-Help',
      },
      {
        'title': 'Deep Work',
        'author': 'Cal Newport',
        'coverImage': null,
        'category': 'Psychology',
      },
    ];

    final int totalResults = allSearchResults.length;
    final int itemsToShow = displayedItemsCount.clamp(0, totalResults);
    final JSONList displayedResults = allSearchResults.sublist(0, itemsToShow);

    final bool hasMoreResults = itemsToShow < totalResults;

    final String headerTitle = getHeaderTitle();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RLTypography.headingMedium(headerTitle),

        const Spacing.height(4),

        Text(
          '$totalResults titles found',
          style: RLTypography.bodyMediumStyle.copyWith(color: RLDS.textSecondary),
        ),

        const Spacing.height(16),

        // Scrollable results list
        Expanded(
          child: ListView(
            padding: EdgeInsets.zero,
            children: SearchResultsListContent(displayedResults, hasMoreResults),
          ),
        ),
      ],
    );
  }

  List<Widget> SearchResultsListContent(JSONList displayedResults, bool hasMoreResults) {
    final List<Widget> content = List<Widget>.from(SearchResultCards(displayedResults));

    content.add(const Spacing.height(16));

    content.add(RenderIf.condition(hasMoreResults, LoadNextButton(), const SizedBox.shrink()));

    return content;
  }

  String getHeaderTitle() {
    final bool isGenreFilter = selectedGenre != null;

    if (isGenreFilter) {
      return selectedGenre!;
    }

    return RLUIStrings.SEARCH_RESULTS_TITLE;
  }

  List<Widget> SearchResultCards(JSONList books) {
    return books.map((book) {
      final String bookTitle = book['title'] ?? '';
      final String bookAuthor = book['author'] ?? '';
      final String? coverImagePath = book['coverImage'];

      return BookListCard(
        title: bookTitle,
        author: bookAuthor,
        coverImagePath: coverImagePath,
      );
    }).toList();
  }

  static final Widget ArrowDownIcon = const Icon(
    Icons.arrow_downward,
    color: RLDS.info,
    size: 16,
  );

  Widget LoadNextButton() {
    return RLCard.subtle(
      padding: const EdgeInsets.symmetric(vertical: RLDS.spacing12),
      borderColor: RLDS.info.withValues(alpha: 0.3),
      onTap: loadMoreResults,
      child: Div.row([
        Text(
          RLUIStrings.LOAD_NEXT_LABEL,
          style: RLTypography.bodyMediumStyle.copyWith(color: RLDS.info),
        ),

        const Spacing.width(8),

        ArrowDownIcon,
      ], mainAxisAlignment: MainAxisAlignment.center),
    );
  }
}
