import 'package:flutter/material.dart';
import '../../widgets/navBar.dart';
import '../../widgets/business_card/card_background.dart';
import '../../theme/colors.dart';
import '../../theme/spacing.dart';
import 'widgets/search_bar_widget.dart';
import 'widgets/filter_button.dart';
import 'widgets/filter_icon_button.dart';
import 'widgets/card_list_item.dart';
import 'widgets/category_section.dart';
import 'utils/card_filter_utils.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  bool _showCategories = false;
  String _searchQuery = '';
  
  // Category expansion state
  final Map<String, bool> _expandedCategories = {
    'School': true,
    'My Startup': true,
    'Stores': true,
  };

  // Sample business cards data with categories
  final List<Map<String, dynamic>> _businessCards = [
    {
      'name': 'Imed Bouchrika',
      'organization': 'ENSIA',
      'jobTitle': 'SWE Professor',
      'background': CardBackground.purple,
      'category': 'School',
    },
    {
      'name': 'Karim Lounis',
      'organization': 'ENSIA',
      'jobTitle': 'ITE Professor',
      'background': CardBackground.gold,
      'category': 'School',
    },
    {
      'name': 'Imed Bouchrika',
      'organization': 'Sidi Abdellah Market',
      'jobTitle': 'Fruits Table',
      'background': CardBackground.greenBlue,
      'category': 'Stores',
    },
    {
      'name': 'Bouchrika Imed',
      'organization': 'Sidi Abdellah Market',
      'jobTitle': 'Vegtebals Table',
      'background': CardBackground.grey,
      'category': 'Stores',
    },
  ];

  void _onTabChange(int index) {
    setState(() {
      _currentIndex = index;
    });
    // TODO: Navigate to different screens based on index
  }

  List<Map<String, dynamic>> get _filteredCards {
    return CardFilterUtils.filterCards(_businessCards, _searchQuery);
  }

  Map<String, List<Map<String, dynamic>>> get _groupedCards {
    return CardFilterUtils.groupByCategory(_filteredCards);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              child: Column(
                children: [
                  const SizedBox(height: AppSpacing.sm),
                  // Title
                  const Text(
                    'My Cards',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: AppColors.lightTextPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  // Search Bar
                  SearchBarWidget(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  // Filter buttons
                  Row(
                    children: [
                      FilterButton(
                        text: 'Show Categories',
                        isActive: _showCategories,
                        onTap: () {
                          setState(() {
                            _showCategories = !_showCategories;
                          });
                        },
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      FilterIconButton(
                        svgPath: 'assets/icons/candle.svg',
                        onTap: () {
                          // TODO: Implement filter functionality
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            // Business Cards List
            Expanded(
              child: _showCategories ? _buildCategorizedView() : _buildListView(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        activeIndex: _currentIndex,
        onTabChange: _onTabChange,
      ),
    );
  }

  Widget _buildListView() {
    final cards = _filteredCards;
    return ListView.builder(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
      ),
      itemCount: cards.length,
      itemBuilder: (context, index) {
        final card = cards[index];
        return CardListItem(card: card);
      },
    );
  }

  Widget _buildCategorizedView() {
    final grouped = _groupedCards;
    final categories = grouped.keys.toList();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        final cards = grouped[category]!;
        final isExpanded = _expandedCategories[category] ?? true;

        return CategorySection(
          category: category,
          cards: cards,
          isExpanded: isExpanded,
          onToggle: () {
            setState(() {
              _expandedCategories[category] = !isExpanded;
            });
          },
        );
      },
    );
  }
}
