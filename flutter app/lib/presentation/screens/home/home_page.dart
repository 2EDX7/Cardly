import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../logic/cubits/card/card_cubit.dart';
import '../../../logic/cubits/card/card_state.dart';
import '../../widgets/business_card/card_background.dart';
import '../../theme/spacing.dart';
import 'widgets/search_bar_widget.dart';
import 'widgets/filter_button.dart';
import 'widgets/filter_icon_button.dart';
import 'widgets/card_list_item.dart';
import 'widgets/category_section.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  bool _showCategories = false;
  
  // Category expansion state
  final Map<String, bool> _expandedCategories = {};

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                  Text(
                    'My Cards',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onBackground,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  // Search Bar
                  SearchBarWidget(
                    controller: _searchController,
                    onChanged: (value) {
                      context.read<CardCubit>().setSearchQuery(value);
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
              child: BlocBuilder<CardCubit, CardState>(
                builder: (context, state) {
                  if (state is CardLoading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  
                  if (state is CardError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, size: 48, color: Colors.red),
                          const SizedBox(height: 16),
                          Text(
                            state.message,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.red),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => context.read<CardCubit>().loadCards(),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }
                  
                  if (state is CardLoaded) {
                    if (state.filteredCards.isEmpty) {
                      return const Center(
                        child: Text('No cards found'),
                      );
                    }
                    
                    return _showCategories 
                        ? _buildCategorizedView(state) 
                        : _buildListView(state);
                  }
                  
                  return const Center(
                    child: Text('No cards available'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListView(CardLoaded state) {
    final cards = state.filteredCards;
    return ListView.builder(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
      ),
      itemCount: cards.length,
      itemBuilder: (context, index) {
        final card = cards[index];
        // Convert CardInfo to Map for compatibility with CardListItem
        final cardMap = {
          'name': card.name,
          'organization': card.organization,
          'jobTitle': card.jobTitle,
          'background': card.background ?? CardBackground.defaultGradient,
          'category': card.category ?? 'Uncategorized',
        };
        
        return Dismissible(
          key: Key(card.email), // Use email as unique identifier
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: AppSpacing.lg),
            margin: const EdgeInsets.only(bottom: AppSpacing.lg),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.delete,
              color: Colors.white,
              size: 32,
            ),
          ),
          confirmDismiss: (direction) async {
            return await showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Delete Card'),
                  content: Text('Are you sure you want to delete ${card.name}\'s card?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                      child: const Text('Delete'),
                    ),
                  ],
                );
              },
            );
          },
          onDismissed: (direction) {
            context.read<CardCubit>().deleteCard(card.email);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${card.name}\'s card deleted'),
                action: SnackBarAction(
                  label: 'Undo',
                  onPressed: () {
                    // Re-add the card
                    context.read<CardCubit>().addCard(card);
                  },
                ),
              ),
            );
          },
          child: CardListItem(card: cardMap),
        );
      },
    );
  }

  Widget _buildCategorizedView(CardLoaded state) {
    final grouped = state.cardsByCategory;
    final categories = grouped.keys.toList();

    if (categories.isEmpty) {
      return const Center(child: Text('No categories found'));
    }

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
          onDeleteCard: (cardEmail) {
            final cardToDelete = cards.firstWhere((c) => c.email == cardEmail);
            showDialog(
              context: context,
              builder: (BuildContext dialogContext) {
                return AlertDialog(
                  title: const Text('Delete Card'),
                  content: Text('Are you sure you want to delete ${cardToDelete.name}\'s card?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(dialogContext).pop();
                        context.read<CardCubit>().deleteCard(cardEmail);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${cardToDelete.name}\'s card deleted'),
                            action: SnackBarAction(
                              label: 'Undo',
                              onPressed: () {
                                context.read<CardCubit>().addCard(cardToDelete);
                              },
                            ),
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                      child: const Text('Delete'),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }
}
