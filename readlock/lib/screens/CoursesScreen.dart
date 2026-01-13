// Courses list screen showing available courses
// Clean card-based layout with course selection

import 'package:flutter/material.dart' hide Typography;
import 'package:readlock/MainNavigation.dart';
import 'package:readlock/screens/ReaderPassScreen.dart';
import 'package:readlock/utility_widgets/Utility.dart';
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/constants/RLTheme.dart';

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
  final TextEditingController searchController =
      TextEditingController();
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

  void handlePromoBannerTap() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const ReaderPassScreen(),
        transitionsBuilder:
            (context, animation, secondaryAnimation, child) {
              const Offset begin = Offset(0.0, 1.0);
              const Offset end = Offset.zero;
              const Curve curve = Curves.easeInOut;

              final Animatable<Offset> tween = Tween(
                begin: begin,
                end: end,
              ).chain(CurveTween(curve: curve));

              final Animation<Offset> offsetAnimation = animation.drive(
                tween,
              );

              return SlideTransition(
                position: offsetAnimation,
                child: child,
              );
            },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool hasSearchText = searchController.text.isNotEmpty;
    final bool shouldShowSearchResults =
        hasSearchText || selectedGenre != null;
    final bool isGenreSelected = selectedGenre != null;
    final bool shouldShowSearchBar = !isGenreSelected;
    final bool shouldShowCategories = !hasSearchText;

    return Scaffold(
      backgroundColor: RLTheme.backgroundDark,
      body: SafeArea(
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
        // Promotional banner (no padding)
        SeasonPromoBanner(),

        // Main content (with padding)
        Padding(
          padding: const EdgeInsets.all(24),
          child: Div.column([
            // Search heading
            RLTypography.headingLarge('Search'),

            const Spacing.height(24),

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

            // Bottom spacing for floating navigation
            const Spacing.height(FLOATING_NAV_BOTTOM_OFFSET),
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
        // Promotional banner (no padding)
        SeasonPromoBanner(),

        // Fixed header content (with padding)
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          child: Div.column([
            // Search heading
            RLTypography.headingLarge('Search'),

            const Spacing.height(24),

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
            padding: const EdgeInsets.fromLTRB(24, 0, 24, FLOATING_NAV_BOTTOM_OFFSET),
            child: SearchResults(),
          ),
        ),
      ],
    );
  }

  Widget SeasonPromoBanner() {
    return GestureDetector(
      onTap: handlePromoBannerTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 16,
        ),
        color: Colors.black,
        child: Div.row([
          RLTypography.bodyMedium(
            'Outperformers do not start tomorrow - Reader Pass -25%',
            color: Colors.white,
          ),
        ], mainAxisAlignment: MainAxisAlignment.center),
      ),
    );
  }

  Widget MockSearchBar() {
    final BoxDecoration searchBarDecoration = BoxDecoration(
      color: RLTheme.backgroundLight.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: RLTheme.grey300.withValues(alpha: 0.3)),
    );

    final Widget SearchIcon = const Icon(
      Icons.search,
      color: RLTheme.textSecondary,
      size: 20,
    );

    return RenderIf.condition(
      isSearchActive,
      ActiveSearchBar(
        searchBarDecoration: searchBarDecoration,
        searchIcon: SearchIcon,
      ),
      InactiveSearchBar(
        searchBarDecoration: searchBarDecoration,
        searchIcon: SearchIcon,
      ),
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
          horizontal: 16,
          vertical: 12,
        ),
        decoration: searchBarDecoration,
        child: Div.row([
          searchIcon,

          const Spacing.width(12),

          RLTypography.text(
            'Title or author...',
            color: RLTheme.textSecondary,
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
      color: RLTheme.textSecondary,
      size: 20,
    );

    final bool hasSearchText = searchController.text.isNotEmpty;

    final Color borderColor = hasSearchText
        ? RLTheme.primaryBlue
        : RLTheme.grey300.withValues(alpha: 0.3);

    final double borderWidth = hasSearchText ? 1.5 : 1;

    final BoxDecoration activeSearchBarDecoration = BoxDecoration(
      color: RLTheme.backgroundLight.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: borderColor, width: borderWidth),
    );

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
              hintText: 'Title or author...',
              hintStyle: RLTypography.bodyMediumStyle.copyWith(
                color: RLTheme.textSecondary,
              ),
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
            onChanged: (searchText) {
              setState(() {});
            },
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
        RLTypography.text('Genres', color: RLTheme.textSecondary),
      ], mainAxisAlignment: MainAxisAlignment.start),

      const Spacing.height(12),

      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: CategoryChips(categories),
      ),
    ], crossAxisAlignment: CrossAxisAlignment.start);
  }

  List<Widget> CategoryChips(List<String> categories) {
    return categories.map((category) {
      final bool isSelected = selectedGenre == category;

      final BoxDecoration chipDecoration = BoxDecoration(
        color: isSelected
            ? RLTheme.primaryBlue
            : RLTheme.backgroundLight.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: RLTheme.primaryBlue.withValues(alpha: 0.3),
        ),
      );

      final Color chipTextColor = isSelected
          ? Colors.white
          : RLTheme.primaryBlue;

      return GestureDetector(
        onTap: () {
          if (isSelected) {
            clearGenreSelection();
          } else {
            selectGenre(category);
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          decoration: chipDecoration,
          child: RLTypography.text(category, color: chipTextColor),
        ),
      );
    }).toList();
  }

  Widget TrendingHeader() {
    return Div.column([
      Div.row([
        RLTypography.headingMedium('Others are reading'),
      ], mainAxisAlignment: MainAxisAlignment.start),

      const Spacing.height(4),

      Div.row([
        RLTypography.text(
          'Popular titles this week',
          color: RLTheme.textSecondary,
        ),
      ], mainAxisAlignment: MainAxisAlignment.start),
    ], crossAxisAlignment: CrossAxisAlignment.start);
  }

  Widget TrendingBooksList() {
    final List<Map<String, dynamic>> trendingBooks = [
      {
        'title': 'Design of Everyday Things',
        'author': 'Don Norman',
        'progress': 0.65,
        'coverImage': 'covers/doet-cover.png',
      },
      {
        'title': 'Atomic Habits',
        'author': 'James Clear',
        'progress': 0.40,
        'coverImage': null,
      },
      {
        'title': 'Deep Work',
        'author': 'Cal Newport',
        'progress': 0.85,
        'coverImage': null,
      },
      {
        'title': 'Thinking, Fast and Slow',
        'author': 'Daniel Kahneman',
        'progress': 0.22,
        'coverImage': null,
      },
      {
        'title': 'Hooked',
        'author': 'Nir Eyal',
        'progress': 0.55,
        'coverImage': null,
      },
    ];

    return Div.column(
      TrendingBookCards(trendingBooks),
      crossAxisAlignment: CrossAxisAlignment.start,
    );
  }

  List<Widget> TrendingBookCards(List<Map<String, dynamic>> books) {
    return books.map((book) {
      final String bookTitle = book['title'] ?? '';
      final String bookAuthor = book['author'] ?? '';
      final String? coverImagePath = book['coverImage'];

      final BoxDecoration cardDecoration = BoxDecoration(
        color: RLTheme.backgroundLight.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: RLTheme.grey300.withValues(alpha: 0.3),
        ),
      );

      final BoxDecoration coverPlaceholderDecoration = BoxDecoration(
        color: RLTheme.primaryBlue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: RLTheme.primaryBlue.withValues(alpha: 0.2),
        ),
      );

      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: cardDecoration,
        child: Div.row([
          // Book cover
          BookCoverWidget(
            coverImagePath: coverImagePath,
            coverPlaceholderDecoration: coverPlaceholderDecoration,
          ),

          const Spacing.width(12),

          // Book info
          Expanded(
            child: Div.column([
              RLTypography.bodyLarge(bookTitle),

              const Spacing.height(4),

              RLTypography.text(
                bookAuthor,
                color: RLTheme.textSecondary,
              ),
            ], crossAxisAlignment: CrossAxisAlignment.start),
          ),

          // Bookmark icon
          Container(
            margin: const EdgeInsets.only(top: 8),
            child: const Icon(
              Icons.bookmark_border,
              color: Colors.grey,
              size: 24,
            ),
          ),
        ]),
      );
    }).toList();
  }

  Widget BookCoverWidget({
    required String? coverImagePath,
    required BoxDecoration coverPlaceholderDecoration,
  }) {
    final bool hasCover = coverImagePath != null;

    if (hasCover) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Image.asset(
          coverImagePath,
          width: 40,
          height: 60,
          fit: BoxFit.cover,
        ),
      );
    }

    return Container(
      width: 40,
      height: 60,
      decoration: coverPlaceholderDecoration,
      child: const Icon(
        Icons.book,
        color: RLTheme.primaryBlue,
        size: 20,
      ),
    );
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
    final List<Map<String, dynamic>> allSearchResults = [
      {
        'title': 'The Design of Everyday Things',
        'author': 'Don Norman',
        'coverImage': 'covers/doet-cover.png',
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
      {
        'title': 'Hooked',
        'author': 'Nir Eyal',
        'coverImage': null,
        'category': 'Design',
      },
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
    final List<Map<String, dynamic>> displayedResults = allSearchResults
        .sublist(0, itemsToShow);

    final bool hasMoreResults = itemsToShow < totalResults;

    final String headerTitle = getHeaderTitle();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RLTypography.headingMedium(headerTitle),

        const Spacing.height(4),

        RLTypography.text(
          '$totalResults titles found',
          color: RLTheme.textSecondary,
        ),

        const Spacing.height(16),

        // Scrollable results list
        Expanded(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              ...SearchResultCards(displayedResults),

              const Spacing.height(16),

              RenderIf.condition(
                hasMoreResults,
                LoadNextButton(),
                const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String getHeaderTitle() {
    final bool isGenreFilter = selectedGenre != null;

    if (isGenreFilter) {
      return selectedGenre!;
    }

    return 'Search Results';
  }

  List<Widget> SearchResultCards(List<Map<String, dynamic>> books) {
    return books.map((book) {
      final String bookTitle = book['title'] ?? '';
      final String bookAuthor = book['author'] ?? '';
      final String? coverImagePath = book['coverImage'];

      final BoxDecoration cardDecoration = BoxDecoration(
        color: RLTheme.backgroundLight.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: RLTheme.grey300.withValues(alpha: 0.3),
        ),
      );

      final BoxDecoration coverPlaceholderDecoration = BoxDecoration(
        color: RLTheme.primaryBlue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: RLTheme.primaryBlue.withValues(alpha: 0.2),
        ),
      );

      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: cardDecoration,
        child: Div.row([
          // Book cover
          SearchResultBookCover(
            coverImagePath: coverImagePath,
            coverPlaceholderDecoration: coverPlaceholderDecoration,
          ),

          const Spacing.width(12),

          // Book info
          Expanded(
            child: Div.column([
              RLTypography.bodyLarge(bookTitle),

              const Spacing.height(4),

              RLTypography.text(
                bookAuthor,
                color: RLTheme.textSecondary,
              ),
            ], crossAxisAlignment: CrossAxisAlignment.start),
          ),

          // Bookmark icon
          Container(
            margin: const EdgeInsets.only(top: 8),
            child: const Icon(
              Icons.bookmark_border,
              color: Colors.grey,
              size: 24,
            ),
          ),
        ]),
      );
    }).toList();
  }

  Widget SearchResultBookCover({
    required String? coverImagePath,
    required BoxDecoration coverPlaceholderDecoration,
  }) {
    final bool hasCover = coverImagePath != null;

    if (hasCover) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Image.asset(
          coverImagePath,
          width: 40,
          height: 60,
          fit: BoxFit.cover,
        ),
      );
    }

    return Container(
      width: 40,
      height: 60,
      decoration: coverPlaceholderDecoration,
      child: const Icon(
        Icons.book,
        color: RLTheme.primaryBlue,
        size: 20,
      ),
    );
  }

  Widget LoadNextButton() {
    final BoxDecoration buttonDecoration = BoxDecoration(
      color: RLTheme.backgroundLight.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: RLTheme.primaryBlue.withValues(alpha: 0.3),
      ),
    );

    return GestureDetector(
      onTap: loadMoreResults,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: buttonDecoration,
        child: Div.row([
          RLTypography.text('Load next', color: RLTheme.primaryBlue),

          const Spacing.width(8),

          const Icon(
            Icons.arrow_downward,
            color: RLTheme.primaryBlue,
            size: 16,
          ),
        ], mainAxisAlignment: MainAxisAlignment.center),
      ),
    );
  }
}
