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
import '../../widgets/business_card/business_card.dart';
import '../../widgets/business_card/card_background.dart';

/// Custom widget for swipe-to-reveal delete button with expandable card
class _SwipeDeleteCard extends StatefulWidget {
  final CardInfo card;
  final String cardIdKey;
  final VoidCallback onDeleteConfirmed;
  final AppLocalizations l10n;

  const _SwipeDeleteCard({
    required Key key,
    required this.card,
    required this.cardIdKey,
    required this.onDeleteConfirmed,
    required this.l10n,
  }) : super(key: key);

  @override
  State<_SwipeDeleteCard> createState() => _SwipeDeleteCardState();
}

class _SwipeDeleteCardState extends State<_SwipeDeleteCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  double _dragOffset = 0;
  double _verticalDragOffset = 0;
  final double _deleteButtonWidth = 80;
  final double _verticalDragThreshold = 50;
  bool _isExpanded = false;
  DateTime _lastTap = DateTime.now();
  bool _isVerticalDragging = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    if (_isExpanded) return; // Disable swipe when expanded
    setState(() {
      _dragOffset =
          (_dragOffset + details.delta.dx).clamp(-_deleteButtonWidth, 0);
    });
  }

  void _handleDragEnd(DragEndDetails details) {
    if (_isExpanded) return; // Disable swipe when expanded
    final threshold = _deleteButtonWidth * 0.5;
    if (_dragOffset.abs() > threshold) {
      _animationController.forward();
      setState(() {
        _dragOffset = -_deleteButtonWidth;
      });
    } else {
      _animationController.reverse();
      setState(() {
        _dragOffset = 0;
      });
    }
  }

  void _handleVerticalDragStart(DragStartDetails details) {
    setState(() {
      _isVerticalDragging = true;
    });
  }

  void _handleVerticalDragUpdate(DragUpdateDetails details) {
    setState(() {
      _verticalDragOffset += details.delta.dy;
    });
  }

  void _handleVerticalDragEnd(DragEndDetails details) {
    // Slide down to expand (positive offset > threshold)
    if (!_isExpanded && _verticalDragOffset > _verticalDragThreshold) {
      setState(() {
        _isExpanded = true;
        _dragOffset = 0;
      });
    }
    // Slide up to collapse (negative offset < -threshold)
    else if (_isExpanded && _verticalDragOffset < -_verticalDragThreshold) {
      setState(() {
        _isExpanded = false;
        _dragOffset = 0;
      });
    }

    setState(() {
      _verticalDragOffset = 0;
      _isVerticalDragging = false;
    });
  }

  void _showDeleteConfirmation() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(widget.l10n.deleteCard),
          content: Text(widget.l10n.areYouSureDeleteCard(widget.card.name)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(widget.l10n.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: Text(widget.l10n.delete),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      widget.onDeleteConfirmed();
      _animationController.reverse();
      setState(() {
        _dragOffset = 0;
      });
    }
  }

  void _handleCardTap() {
    final now = DateTime.now();
    final timeSinceLastTap = now.difference(_lastTap).inMilliseconds;
    _lastTap = now;

    // Ignore if it's a potential double-tap (will be handled by the card's double-tap)
    if (timeSinceLastTap < 300) return;

    // Toggle expand/collapse
    setState(() {
      _isExpanded = !_isExpanded;
      _dragOffset = 0; // Reset drag when expanding/collapsing
    });
  }

  void _handleEdit() {
    Navigator.of(context)
        .pushNamed(
      AppRoutes.editCard,
      arguments: widget.card,
    )
        .then((updatedCard) {
      if (updatedCard is CardInfo) {
        context.read<CardCubit>().updateCard(updatedCard);
      }
    });
  }

  void _handleShare() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ShowQrCodeScreen(card: widget.card),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final compactHeight = 180.0;
    final expandedHeight = 280.0; // Use default BusinessCard height
    final currentHeight = _isExpanded ? expandedHeight : compactHeight;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Card Container with swipe (only in compact mode)
          Container(
            height: currentHeight,
            decoration: _isExpanded
                ? null
                : BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(24),
                  ),
            child: _isExpanded
                ? GestureDetector(
                    onTap: _handleCardTap,
                    onVerticalDragStart: _handleVerticalDragStart,
                    onVerticalDragUpdate: _handleVerticalDragUpdate,
                    onVerticalDragEnd: _handleVerticalDragEnd,
                    child: BusinessCard(
                      name: widget.card.name,
                      organization: widget.card.organization,
                      jobTitle: widget.card.jobTitle,
                      email: widget.card.email,
                      phone: widget.card.phone,
                      location: widget.card.location,
                      about: widget.card.about,
                      website: widget.card.website,
                      background: widget.card.background ??
                          CardBackground.defaultGradient,
                      compactCard: false,
                      width: double.infinity,
                    ),
                  )
                : Stack(
                    children: [
                      // Delete button area (only in compact mode)
                      Positioned(
                        right: 0,
                        top: 0,
                        bottom: 0,
                        width: _deleteButtonWidth,
                        child: GestureDetector(
                          onTap: _showDeleteConfirmation,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(24),
                                bottomRight: Radius.circular(24),
                              ),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.delete,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Card with drag handler
                      GestureDetector(
                        onHorizontalDragUpdate: _handleDragUpdate,
                        onHorizontalDragEnd: _handleDragEnd,
                        child: Transform.translate(
                          offset: Offset(_dragOffset, 0),
                          child: GestureDetector(
                            onTap: _handleCardTap,
                            onVerticalDragStart: _handleVerticalDragStart,
                            onVerticalDragUpdate: _handleVerticalDragUpdate,
                            onVerticalDragEnd: _handleVerticalDragEnd,
                            child: BusinessCard(
                              name: widget.card.name,
                              organization: widget.card.organization,
                              jobTitle: widget.card.jobTitle,
                              background: widget.card.background ??
                                  CardBackground.defaultGradient,
                              compactCard: true,
                              width: double.infinity,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
          // Action buttons (only show when expanded)
          if (_isExpanded)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.md),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _ActionButton(
                    icon: Icons.edit,
                    label: widget.l10n.edit,
                    onTap: _handleEdit,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  _ActionButton(
                    icon: Icons.share,
                    label: widget.l10n.share,
                    onTap: _handleShare,
                    color: Colors.blue,
                  ),
                  _ActionButton(
                    icon: Icons.delete,
                    label: widget.l10n.delete,
                    onTap: _showDeleteConfirmation,
                    color: Colors.red,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Action button widget for edit/share/delete
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: AppSpacing.xs),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  bool _showCategories = false;
  String? _selectedCategory; // Track selected category filter

  // Category expansion state
  final Map<String, bool> _expandedCategories = {};

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showCategoryFilterDialog() {
    final state = context.read<CardCubit>().state;
    if (state is! CardLoaded) return;

    // Get all unique categories from ALL cards (not filtered)
    final allCategories = state.cards
        .map((card) => card.category ?? 'Uncategorized')
        .toSet()
        .toList();
    allCategories.sort();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Filter by Category'),
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          content: SizedBox(
            width: double.maxFinite,
            child: allCategories.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('No categories available'),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: allCategories.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        final isSelected = _selectedCategory == null;
                        return ListTile(
                          leading: Icon(
                            Icons.clear_all,
                            color: isSelected
                                ? Theme.of(context).colorScheme.primary
                                : null,
                          ),
                          title: Text(
                            'Show All',
                            style: TextStyle(
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isSelected
                                  ? Theme.of(context).colorScheme.primary
                                  : null,
                            ),
                          ),
                          trailing: isSelected
                              ? Icon(
                                  Icons.check,
                                  color: Theme.of(context).colorScheme.primary,
                                )
                              : null,
                          onTap: () {
                            setState(() {
                              _selectedCategory = null;
                            });
                            context.read<CardCubit>().filterByCategory(null);
                            Navigator.of(dialogContext).pop();
                          },
                        );
                      }
                      final category = allCategories[index - 1];
                      final isSelected = _selectedCategory == category;
                      return ListTile(
                        leading: Icon(
                          Icons.label_outline,
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : null,
                        ),
                        title: Text(
                          category,
                          style: TextStyle(
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isSelected
                                ? Theme.of(context).colorScheme.primary
                                : null,
                          ),
                        ),
                        trailing: isSelected
                            ? Icon(
                                Icons.check,
                                color: Theme.of(context).colorScheme.primary,
                              )
                            : null,
                        onTap: () {
                          setState(() {
                            _selectedCategory = category;
                          });
                          context.read<CardCubit>().filterByCategory(category);
                          Navigator.of(dialogContext).pop();
                        },
                      );
                    },
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Future<String?> _showCategorySelectionDialog(CardInfo card) async {
    final state = context.read<CardCubit>().state;
    List<String> existingCategories = ['Uncategorized'];

    if (state is CardLoaded) {
      existingCategories = state.cards
          .map((card) => card.category ?? 'Uncategorized')
          .toSet()
          .toList();
      existingCategories.sort();
    }

    return showDialog<String>(
      context: context,
      builder: (dialogContext) {
        String? selectedCategory = card.category ?? 'Uncategorized';
        final TextEditingController newCategoryController =
            TextEditingController();
        bool isCreatingNew = false;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('Select Category for ${card.name}'),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: existingCategories.length,
                        itemBuilder: (context, index) {
                          final category = existingCategories[index];
                          final isSelected = selectedCategory == category;
                          return RadioListTile<String>(
                            value: category,
                            groupValue: selectedCategory,
                            title: Text(category),
                            selected: isSelected,
                            onChanged: (value) {
                              setDialogState(() {
                                selectedCategory = value;
                                isCreatingNew = false;
                              });
                            },
                          );
                        },
                      ),
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.add),
                      title: const Text('Create New Category'),
                      onTap: () {
                        setDialogState(() {
                          isCreatingNew = !isCreatingNew;
                        });
                      },
                    ),
                    if (isCreatingNew)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: TextField(
                          controller: newCategoryController,
                          autofocus: true,
                          decoration: const InputDecoration(
                            labelText: 'New Category Name',
                            border: OutlineInputBorder(),
                            hintText: 'e.g., Work, Personal',
                          ),
                          onSubmitted: (value) {
                            if (value.trim().isNotEmpty) {
                              Navigator.of(dialogContext).pop(value.trim());
                            }
                          },
                        ),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(null),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (isCreatingNew) {
                      final newCategory = newCategoryController.text.trim();
                      if (newCategory.isNotEmpty) {
                        Navigator.of(dialogContext).pop(newCategory);
                      }
                    } else {
                      Navigator.of(dialogContext).pop(selectedCategory);
                    }
                  },
                  child: const Text('Confirm'),
                ),
              ],
            );
          },
        );
      },
    );
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
    return BlocBuilder<CardCubit, CardState>(
      builder: (context, state) {
        final hasCards = state is CardLoaded && state.cards.isNotEmpty;

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            toolbarHeight: 0, // Hide AppBar completely
          ),
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with title on top left
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.lg,
                    AppSpacing.lg,
                    AppSpacing.md,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        l10n.myCards,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onBackground,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      // Search Bar
                      Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Theme.of(context)
                                .colorScheme
                                .outline
                                .withOpacity(0.2),
                          ),
                        ),
                        child: TextField(
                          controller: _searchController,
                          onChanged: (value) {
                            context.read<CardCubit>().searchCards(value);
                          },
                          decoration: InputDecoration(
                            hintText: l10n.searchForCard,
                            hintStyle: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant
                                  .withOpacity(0.6),
                              fontSize: 15,
                            ),
                            prefixIcon: Icon(
                              Icons.search,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: AppSpacing.md,
                            ),
                          ),
                        ),
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
                                // When disabling show categories, also clear category filter
                                if (!_showCategories &&
                                    _selectedCategory != null) {
                                  _selectedCategory = null;
                                  context
                                      .read<CardCubit>()
                                      .filterByCategory(null);
                                }
                              });
                            },
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          IconButton(
                            onPressed: _showCategories
                                ? () => _showCategoryFilterDialog()
                                : null,
                            icon: Icon(
                              Icons.filter_alt,
                              color: _showCategories
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant
                                      .withOpacity(0.3),
                            ),
                            style: IconButton.styleFrom(
                              backgroundColor: _showCategories
                                  ? Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withOpacity(0.1)
                                  : Theme.of(context)
                                      .colorScheme
                                      .surfaceVariant
                                      .withOpacity(0.3),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
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
                              const Icon(Icons.error_outline,
                                  size: 48, color: Colors.red),
                              const SizedBox(height: 16),
                              Text(
                                state.message,
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.red),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () =>
                                    context.read<CardCubit>().loadCards(),
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
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                                const SizedBox(height: AppSpacing.lg),
                                Text(
                                  l10n.noCardsFound,
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
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
      },
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
              onPressed: () async {
                final result = await Navigator.of(context).pushNamed(
                  AppRoutes.addCard,
                );
                if (result is CardInfo && mounted) {
                  // Show category selection dialog
                  final category = await _showCategorySelectionDialog(result);
                  if (category != null && mounted) {
                    final updatedCard = result.copyWith(category: category);
                    await context.read<CardCubit>().addCard(updatedCard);
                  }
                }
              },
              icon: const Icon(Icons.add),
              label: const Text('Collect Your First Card'),
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
            const SizedBox(height: AppSpacing.md),
            OutlinedButton.icon(
              onPressed: () async {
                final result = await Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ScanQrScreen()),
                );
                if (result is CardInfo && mounted) {
                  // Show category selection dialog
                  final category = await _showCategorySelectionDialog(result);
                  if (category != null && mounted) {
                    final updatedCard = result.copyWith(category: category);
                    await context.read<CardCubit>().addCard(updatedCard);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${result.name} added to your cards'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  }
                }
              },
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text('Quickly Scan QR Code'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl,
                  vertical: AppSpacing.md,
                ),
                side: BorderSide(
                  color: cs.primary,
                  width: 2,
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
        final cardIdKey = card.backendId ?? card.id?.toString() ?? card.email;

        return _SwipeDeleteCard(
          key: Key(cardIdKey),
          card: card,
          cardIdKey: cardIdKey,
          onDeleteConfirmed: () {
            // Remove from UI immediately
            context.read<CardCubit>().removeCardFromState(cardIdKey);

            final undoNotifier = ValueNotifier<bool>(false);
            ScaffoldMessenger.of(context).hideCurrentSnackBar();

            // Show snackbar like the add card snackbars - auto dismisses
            final snackBar = SnackBar(
              content: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(l10n.cardDeleted(card.name)),
                  ),
                  TextButton(
                    onPressed: () {
                      undoNotifier.value = true;
                      context.read<CardCubit>().addCardToState(card);
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    },
                    child: Text(
                      l10n.undo,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.red,
            );

            final snackBarController =
                ScaffoldMessenger.of(context).showSnackBar(snackBar);

            snackBarController.closed.then((_) {
              if (!undoNotifier.value) {
                final backendId = card.backendId;
                final id = card.id;
                if (backendId != null && backendId.isNotEmpty) {
                  context.read<CardCubit>().deleteCardByBackendId(backendId);
                } else if (id != null) {
                  context.read<CardCubit>().deleteCard(id);
                }
              }
            });
          },
          l10n: l10n,
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
          l10n: l10n,
          onToggle: () {
            setState(() {
              _expandedCategories[category] = !isExpanded;
            });
          },
          onDeleteConfirmed: (card) {
            // Remove from UI immediately
            final cardIdKey =
                card.backendId ?? card.id?.toString() ?? card.email;
            context.read<CardCubit>().removeCardFromState(cardIdKey);

            final undoNotifier = ValueNotifier<bool>(false);
            ScaffoldMessenger.of(context).hideCurrentSnackBar();

            // Show snackbar like the add card snackbars - auto dismisses
            final snackBar = SnackBar(
              content: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(l10n.cardDeleted(card.name)),
                  ),
                  TextButton(
                    onPressed: () {
                      undoNotifier.value = true;
                      context.read<CardCubit>().addCardToState(card);
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    },
                    child: Text(
                      l10n.undo,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.red,
            );

            final snackBarController =
                ScaffoldMessenger.of(context).showSnackBar(snackBar);

            snackBarController.closed.then((_) {
              if (!undoNotifier.value) {
                final backendId = card.backendId;
                final id = card.id;
                if (backendId != null && backendId.isNotEmpty) {
                  context.read<CardCubit>().deleteCardByBackendId(backendId);
                } else if (id != null) {
                  context.read<CardCubit>().deleteCard(id);
                }
              }
            });
          },
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
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.xl),
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
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(card.jobTitle,
                        style: TextStyle(color: cs.onSurfaceVariant)),
                    Text(card.organization,
                        style: TextStyle(color: cs.onSurfaceVariant)),
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
            if (card.website.isNotEmpty)
              _InfoRow(icon: Icons.link, label: card.website),
            if (card.shareableId != null && card.shareableId!.isNotEmpty)
              _InfoRow(
                  icon: Icons.share, label: 'Share ID: ${card.shareableId}'),
            if (card.id != null)
              _InfoRow(icon: Icons.badge_outlined, label: 'ID: ${card.id}'),
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
                    style:
                        OutlinedButton.styleFrom(foregroundColor: Colors.red),
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
