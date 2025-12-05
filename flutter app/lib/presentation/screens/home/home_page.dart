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
import 'package:cardly/src/generated/l10n/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context)!;
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
                    l10n.myCards,
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
                        text: l10n.showCategories,
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
                            child: Text(l10n.retry),
                          ),
                        ],
                      ),
                    );
                  }
                  
                  if (state is CardLoaded) {
                    if (state.filteredCards.isEmpty) {
                      return Center(
                        child: Text(l10n.noCardsFound),
                      );
                    }
                    
                    return _showCategories 
                        ? _buildCategorizedView(state, l10n) 
                        : _buildListView(state, l10n);
                  }
                  
                  return Center(
                    child: Text(l10n.noCardsAvailable),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListView(CardLoaded state, AppLocalizations l10n) {
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
          'category': card.category ?? l10n.uncategorized,
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
                  title: Text(l10n.deleteCard),
                  content: Text(l10n.areYouSureDeleteCard(card.name)),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: Text(l10n.cancel),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                      child: Text(l10n.delete),
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
                content: Text(l10n.cardDeleted(card.name)),
                action: SnackBarAction(
                  label: l10n.undo,
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

  Widget _buildCategorizedView(CardLoaded state, AppLocalizations l10n) {
    final grouped = state.cardsByCategory;
    final categories = grouped.keys.toList();

    if (categories.isEmpty) {
      return Center(child: Text(l10n.noCategoriesFound));
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
                  title: Text(l10n.deleteCard),
                  content: Text(l10n.areYouSureDeleteCard(cardToDelete.name)),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      child: Text(l10n.cancel),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(dialogContext).pop();
                        context.read<CardCubit>().deleteCard(cardEmail);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(l10n.cardDeleted(cardToDelete.name)),
                            action: SnackBarAction(
                              label: l10n.undo,
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
                      child: Text(l10n.delete),
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
