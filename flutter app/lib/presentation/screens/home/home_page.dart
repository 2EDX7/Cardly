import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../logic/cubits/card/card_cubit.dart';
import '../../../logic/cubits/card/card_state.dart';
import '../../theme/spacing.dart';
import 'widgets/search_bar_widget.dart';
import 'widgets/filter_button.dart';
import 'widgets/filter_icon_button.dart';
import 'widgets/card_list_item.dart';
import 'widgets/category_section.dart';
import '../../../l10n/app_localizations.dart';
import '../../../data/models/card_info.dart';
import '../../../routes/routes.dart';
import '../qr/show_qr_code_screen.dart';
import '../qr/scan_qr_screen.dart';
import '../card/add_by_id_dialog.dart';

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

  Future<void> _openCardDetails(CardInfo card) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return _CardDetailSheet(
          card: card,
          onEdit: () async {
            Navigator.of(sheetContext).pop();
            final updatedCard = await Navigator.of(context).pushNamed(
              AppRoutes.editCard,
              arguments: card,
            );
            if (updatedCard is CardInfo) {
              await context.read<CardCubit>().updateCard(updatedCard);
            }
          },
          onDelete: () async {
            Navigator.of(sheetContext).pop();
            if (card.id != null) {
              await context.read<CardCubit>().deleteCard(card.id!);
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    print("Building HomePage");
    final l10n = AppLocalizations.of(context)!;
    print("L10n loaded: ${l10n.myCards}");
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            tooltip: 'Add by ID',
            onPressed: () async {
              final result = await showDialog<bool>(
                context: context,
                builder: (_) => BlocProvider.value(
                  value: context.read<CardCubit>(),
                  child: const AddByIdDialog(),
                ),
              );
              if (result == true && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Card added successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const ScanQrScreen()),
          );
          if (result is CardInfo && mounted) {
            await context.read<CardCubit>().addCard(result);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${result.name} added to your cards'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          }
        },
        icon: const Icon(Icons.qr_code_scanner),
        label: const Text('Scan Card'),
      ),
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
                    // Check if user has any cards at all
                    if (state.cards.isEmpty) {
                      return _buildEmptyState(context, l10n);
                    }
                    
                    // User has cards but filtered list is empty
                    if (state.filteredCards.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 64,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            Text(
                              l10n.noCardsFound,
                              style: TextStyle(
                                fontSize: 18,
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    
                    return _showCategories 
                        ? _buildCategorizedView(state, l10n) 
                        : _buildListView(state, l10n);
                  }
                  
                  // Handle CardInitial and any other state - show empty state
                  return _buildEmptyState(context, l10n);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, AppLocalizations l10n) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.credit_card_outlined,
              size: 80,
              color: cs.primary.withOpacity(0.5),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              l10n.noCardsAvailable,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: cs.onBackground,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Start building your digital card collection',
              style: TextStyle(
                fontSize: 16,
                color: cs.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pushNamed(AppRoutes.addCard);
              },
              icon: const Icon(Icons.add),
              label: Text(l10n.createYourFirstCard),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl,
                  vertical: AppSpacing.md,
                ),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
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
        
        final cardIdKey = card.id?.toString() ?? card.email;

        return Dismissible(
          key: Key(cardIdKey),
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
            final id = card.id;
            if (id == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.noCardsFound)),
              );
              return;
            }
            context.read<CardCubit>().deleteCard(id);
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
          child: CardListItem(
            card: card,
            onTap: () => _openCardDetails(card),
          ),
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
          onDeleteCard: (cardId) {
            final cardToDelete = cards.firstWhere((c) => c.id == cardId);
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
                        if (cardToDelete.id != null) {
                          context.read<CardCubit>().deleteCard(cardToDelete.id!);
                        }
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
          onCardTap: (card) => _openCardDetails(card),
        );
      },
    );
  }
}


class _CardDetailSheet extends StatelessWidget {
  final CardInfo card;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CardDetailSheet({
    required this.card,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      card.name,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(card.jobTitle, style: TextStyle(color: cs.onSurfaceVariant)),
                    Text(card.organization, style: TextStyle(color: cs.onSurfaceVariant)),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            _InfoRow(icon: Icons.email_outlined, label: card.email),
            _InfoRow(icon: Icons.phone_outlined, label: card.phone),
            _InfoRow(icon: Icons.location_on_outlined, label: card.location),
            if (card.website.isNotEmpty) _InfoRow(icon: Icons.link, label: card.website),
            if (card.id != null) _InfoRow(icon: Icons.badge_outlined, label: 'ID: ${card.id}'),
            const SizedBox(height: AppSpacing.md),
            Text(card.about, style: TextStyle(color: cs.onSurface)),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit),
                    label: Text(l10n.editCard),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete, color: Colors.red),
                    label: Text(l10n.deleteCard),
                    style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ShowQrCodeScreen(card: card),
                    ),
                  );
                },
                icon: const Icon(Icons.qr_code),
                label: const Text('Share via QR'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: cs.secondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Icon(icon, color: cs.primary),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              label,
              style: TextStyle(color: cs.onSurface),
            ),
          ),
        ],
      ),
    );
  }
}
