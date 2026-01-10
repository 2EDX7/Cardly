import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/card_info.dart';
import '../../../logic/cubits/card/card_cubit.dart';
import '../../../logic/cubits/card/card_state.dart';
import '../../../logic/cubits/profile_card/profile_card_cubit.dart';
import '../../theme/spacing.dart';
import '../../../l10n/app_localizations.dart';
import '../../../routes/routes.dart';

class AddByIdDialog extends StatefulWidget {
  const AddByIdDialog({super.key});

  @override
  State<AddByIdDialog> createState() => _AddByIdDialogState();
}

class _AddByIdDialogState extends State<AddByIdDialog> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _newCategoryController = TextEditingController();
  CardInfo? _previewCard;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _idController.dispose();
    _newCategoryController.dispose();
    super.dispose();
  }

  Future<String?> _pickCategory(CardInfo card) async {
    final l10n = AppLocalizations.of(context)!;
    final state = context.read<CardCubit>().state;
    final categories = <String>{l10n.uncategorized};
    if (state is CardLoaded) {
      categories.addAll(state.cards
          .map((c) => c.category ?? l10n.uncategorized)
          .where((c) => c.trim().isNotEmpty));
    }
    categories.add('New Category');

    String? selected = card.category ?? l10n.uncategorized;
    bool creating = false;
    _newCategoryController.clear();

    return showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Select Category'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ...categories.map((cat) => RadioListTile<String>(
                        value: cat,
                        groupValue: selected,
                        title: Text(cat),
                        onChanged: (v) {
                          setDialogState(() {
                            selected = v;
                            creating = v == 'New Category';
                            if (!creating) _newCategoryController.clear();
                          });
                        },
                      )),
                  if (creating)
                    TextField(
                      controller: _newCategoryController,
                      decoration: const InputDecoration(
                        labelText: 'Category name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(null),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (creating) {
                      final name = _newCategoryController.text.trim();
                      if (name.isEmpty) return;
                      Navigator.of(dialogContext).pop(name);
                    } else {
                      Navigator.of(dialogContext).pop(selected);
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

  Future<void> _fetchCard() async {
    final idText = _idController.text.trim();
    if (idText.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter a card ID';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _previewCard = null;
    });

    try {
      // Use ProfileCardCubit to preview the public profile card
      // We are "searching" for a card by shareable ID
      final card =
          await context.read<ProfileCardCubit>().getCardByShareableId(idText);

      if (card == null) {
        if (mounted) {
          setState(() {
            _errorMessage = 'Card not found with ID: $idText';
            _isLoading = false;
          });
        }
        return;
      }

      if (mounted) {
        setState(() {
          _previewCard = card;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error fetching card: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _addCard() async {
    final idText = _idController.text.trim();
    if (idText.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Collect the card using its shareable ID
      final collected =
          await context.read<CardCubit>().collectCardByShareableId(idText);

      if (collected != null && mounted) {
        final chosen = await _pickCategory(collected);
        final l10n = AppLocalizations.of(context)!;
        final category = chosen ?? l10n.uncategorized;
        await context
            .read<CardCubit>()
            .updateCard(collected.copyWith(category: category));

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Card added as "$category"'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pushNamedAndRemoveUntil(
            AppRoutes.home,
            (route) => false,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error adding card: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Add Card by ID',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),

            // ID Input Field
            TextField(
              controller: _idController,
              decoration: InputDecoration(
                labelText: 'Shareable ID',
                hintText: 'Enter card ID',
                prefixIcon: const Icon(Icons.qr_code),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _fetchCard,
                ),
              ),
              // Changed to text for shareable IDs (alphanumeric strings)
              keyboardType: TextInputType.text,
              onSubmitted: (_) => _fetchCard(),
            ),

            const SizedBox(height: AppSpacing.md),

            // Error Message
            if (_errorMessage != null)
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline,
                        color: Colors.red, size: 20),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),

            // Loading Indicator
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(AppSpacing.lg),
                child: Center(child: CircularProgressIndicator()),
              ),

            // Card Preview
            if (_previewCard != null) ...[
              const SizedBox(height: AppSpacing.md),
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: cs.primaryContainer.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: cs.primary.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: cs.primary,
                          child: Text(
                            _previewCard!.name.isNotEmpty
                                ? _previewCard!.name[0].toUpperCase()
                                : '?',
                            style: TextStyle(
                              color: cs.onPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _previewCard!.name,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              Text(
                                _previewCard!.jobTitle,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: cs.onSurfaceVariant,
                                    ),
                              ),
                              Text(
                                _previewCard!.organization,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: cs.onSurfaceVariant,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    const Divider(),
                    const SizedBox(height: AppSpacing.sm),
                    _InfoItem(icon: Icons.email, text: _previewCard!.email),
                    _InfoItem(icon: Icons.phone, text: _previewCard!.phone),
                    _InfoItem(
                        icon: Icons.location_on, text: _previewCard!.location),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Add Button
              ElevatedButton.icon(
                onPressed: _addCard,
                icon: const Icon(Icons.add),
                label: const Text('Add to My Cards'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
