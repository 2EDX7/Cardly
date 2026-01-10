import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:cardly/presentation/widgets/buildDivider.dart';
import 'package:cardly/presentation/theme/colors.dart';
import 'package:cardly/presentation/theme/spacing.dart';
import 'package:cardly/presentation/theme/typography.dart';
import 'package:cardly/routes/routes.dart';
import "../../../l10n/app_localizations.dart";
import '../../../logic/cubits/card/card_cubit.dart';
import '../../../logic/cubits/card/card_state.dart';
import '../../../logic/cubits/profile_card/profile_card_cubit.dart';
import '../../../data/models/card_info.dart';

class AddCardScreen extends StatefulWidget {
  const AddCardScreen({Key? key}) : super(key: key);

  @override
  State<AddCardScreen> createState() => _AddCardScreenState();
}

class _AddCardScreenState extends State<AddCardScreen> {
  final TextEditingController _cardIdController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  bool _isLoadingCard = false;

  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image != null && mounted) {
        // Show loading indicator
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: CircularProgressIndicator(),
          ),
        );

        try {
          // Try to analyze the image for QR codes
          final controller = MobileScannerController();
          final barcodes = await controller.analyzeImage(image.path);

          if (mounted) {
            Navigator.of(context).pop(); // Close loading dialog
          }

          if (barcodes != null && barcodes.barcodes.isNotEmpty) {
            // QR code found in image
            final code = barcodes.barcodes.first.rawValue;

            if (code != null && code.isNotEmpty && mounted) {
              await _processQrCode(code);
            }
          } else {
            // No QR code found
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('No QR code found in the selected image'),
                  backgroundColor: Colors.orange,
                ),
              );
            }
          }

          await controller.dispose();
        } catch (e) {
          if (mounted) {
            Navigator.of(context).pop(); // Close loading dialog if open
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error scanning QR code: ${e.toString()}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.errorPickingImage(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _processQrCode(String code) async {
    try {
      if (code.startsWith('{')) {
        // JSON legacy format
        final Map<String, dynamic> cardData = jsonDecode(code);
        final CardInfo scannedCard = CardInfo.fromJson(cardData);

        if (mounted) {
          // Show card preview for confirmation
          final shouldAdd = await _showCardPreview(scannedCard);

          if (shouldAdd == true && mounted) {
            // Show loading while adding card
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => const Center(
                child: CircularProgressIndicator(),
              ),
            );

            await context.read<CardCubit>().addCard(scannedCard);

            if (mounted) {
              Navigator.of(context).pop(); // Close loading dialog
              await Future.delayed(const Duration(milliseconds: 100));

              final chosen = await _pickCategory(scannedCard);
              if (chosen == null) return;

              final category = chosen;
              final updatedCard = scannedCard.copyWith(category: category);
              updatedCard.backendId = scannedCard.backendId;
              updatedCard.id = scannedCard.id;
              updatedCard.shareableId = scannedCard.shareableId;
              await context.read<CardCubit>().updateCard(updatedCard);

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Card collected as "$category"'),
                    backgroundColor: Colors.green,
                  ),
                );
                Navigator.of(context).pushNamedAndRemoveUntil(
                  AppRoutes.home,
                  (route) => false,
                );
              }
            }
          }
        }
      } else {
        // Shareable ID format - fetch card first to show preview
        if (mounted) {
          // Show loading while fetching card
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => const Center(
              child: CircularProgressIndicator(),
            ),
          );

          try {
            // Fetch card details for preview
            final card = await context
                .read<ProfileCardCubit>()
                .getCardByShareableId(code);

            if (mounted) {
              Navigator.of(context).pop(); // Close loading dialog
            }

            if (card == null && mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Card not found with ID: $code'),
                  backgroundColor: Colors.red,
                ),
              );
              return;
            }

            if (mounted) {
              // Check if card already exists in collection
              final cardState = context.read<CardCubit>().state;
              if (cardState is CardLoaded) {
                final alreadyExists = cardState.cards.any(
                  (existingCard) => existingCard.shareableId == code,
                );

                if (alreadyExists) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content:
                          Text('You already have this card in your collection'),
                      backgroundColor: Colors.grey,
                    ),
                  );
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    AppRoutes.home,
                    (route) => false,
                  );
                  return;
                }
              }

              // Show card preview for confirmation
              final shouldAdd = await _showCardPreview(card!);

              if (shouldAdd == true && mounted) {
                // Show loading while collecting card
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => const Center(
                    child: CircularProgressIndicator(),
                  ),
                );

                final collected = await context
                    .read<CardCubit>()
                    .collectCardByShareableId(code);

                if (mounted) {
                  Navigator.of(context).pop(); // Close loading dialog
                }

                if (collected == null) {
                  final cubitState = context.read<CardCubit>().state;
                  if (cubitState is CardError &&
                      cubitState.message.contains('already have')) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              'You already have this card in your collection'),
                          backgroundColor: Colors.grey,
                        ),
                      );
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        AppRoutes.home,
                        (route) => false,
                      );
                    }
                  }
                  return;
                }

                if (mounted) {
                  await Future.delayed(const Duration(milliseconds: 100));

                  final chosen = await _pickCategory(collected);
                  if (chosen == null) return;

                  final category = chosen;
                  final updatedCard = collected.copyWith(category: category);
                  updatedCard.backendId = collected.backendId;
                  updatedCard.id = collected.id;
                  updatedCard.shareableId = collected.shareableId;
                  await context.read<CardCubit>().updateCard(updatedCard);

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Card collected as "$category"'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      AppRoutes.home,
                      (route) => false,
                    );
                  }
                }
              }
            }
          } catch (e) {
            if (mounted) {
              Navigator.of(context).pop(); // Close loading dialog if open
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error fetching card: ${e.toString()}'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error processing card: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
    final newCategoryController = TextEditingController();

    return showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Select Category'),
              content: SingleChildScrollView(
                child: Column(
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
                              if (!creating) {
                                newCategoryController.clear();
                              }
                            });
                          },
                        )),
                    if (creating) ...[
                      const SizedBox(height: AppSpacing.md),
                      TextField(
                        controller: newCategoryController,
                        decoration: const InputDecoration(
                          labelText: 'Category name',
                          border: OutlineInputBorder(),
                        ),
                        autofocus: true,
                      ),
                    ],
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
                    if (creating) {
                      final name = newCategoryController.text.trim();
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

  Future<bool?> _showCardPreview(CardInfo card) {
    final cs = Theme.of(context).colorScheme;
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Card Preview'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: cs.primary,
                    child: Text(
                      card.name.isNotEmpty ? card.name[0].toUpperCase() : '?',
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
                          card.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          card.jobTitle,
                          style: TextStyle(
                            color: cs.onSurfaceVariant,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              const Divider(),
              const SizedBox(height: AppSpacing.sm),
              _buildInfoRow(Icons.business, 'Organization', card.organization),
              _buildInfoRow(Icons.email, 'Email', card.email),
              _buildInfoRow(Icons.phone, 'Phone', card.phone),
              _buildInfoRow(Icons.location_on, 'Location', card.location),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Add Card'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _cardIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        automaticallyImplyLeading: false, // Remove back button
        title: Text(
          AppLocalizations.of(context)!.addCard,
          style: AppTextStyles.heading3(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.paddingMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              // "Enter Shareable ID" would be better, but keeping localization key for now
              AppLocalizations.of(context)!.enterCardId,
              style: AppTextStyles.heading2(context),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              AppLocalizations.of(context)!.cardRegisteredInApp,
              style: AppTextStyles.bodySmall(context)
                  .copyWith(color: AppColors.primary),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _cardIdController,
              decoration: InputDecoration(
                // Updated hint
                labelText: 'Shareable ID',
                hintText: 'Enter shareable ID',
              ),
              // Strings allowed now
              keyboardType: TextInputType.text,
            ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoadingCard
                    ? null
                    : () async {
                        final shareableId = _cardIdController.text.trim();
                        if (shareableId.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(l10n.errorCardIdEmpty),
                              backgroundColor: Colors.orange,
                            ),
                          );
                          return;
                        }

                        setState(() {
                          _isLoadingCard = true;
                        });

                        try {
                          // Fetch profile card by shareable ID for preview
                          final card = await context
                              .read<ProfileCardCubit>()
                              .getCardByShareableId(shareableId);

                          if (!mounted) return;

                          if (card == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    'Card not found with ID: $shareableId'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          } else {
                            // Check if card already exists in collection
                            final cardState = context.read<CardCubit>().state;
                            if (cardState is CardLoaded) {
                              final alreadyExists = cardState.cards.any(
                                (existingCard) =>
                                    existingCard.shareableId == shareableId,
                              );

                              if (alreadyExists) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'You already have this card in your collection'),
                                    backgroundColor: Colors.grey,
                                  ),
                                );
                                Navigator.of(context).pushNamedAndRemoveUntil(
                                  AppRoutes.home,
                                  (route) => false,
                                );
                                return;
                              }
                            }

                            // Show preview dialog
                            final shouldAdd = await _showCardPreview(card);

                            if (shouldAdd == true && mounted) {
                              // Add card to collection via API
                              final collected = await context
                                  .read<CardCubit>()
                                  .collectCardByShareableId(shareableId);

                              if (collected == null) {
                                // Check if it's a duplicate error
                                final cubitState =
                                    context.read<CardCubit>().state;
                                if (cubitState is CardError &&
                                    cubitState.message
                                        .contains('already have')) {
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            'You already have this card in your collection'),
                                        backgroundColor: Colors.grey,
                                      ),
                                    );
                                    Navigator.of(context)
                                        .pushNamedAndRemoveUntil(
                                      AppRoutes.home,
                                      (route) => false,
                                    );
                                  }
                                }
                                return;
                              }

                              if (mounted) {
                                // Wait a bit for the state to settle
                                await Future.delayed(
                                    const Duration(milliseconds: 100));

                                // Show category selection
                                final chosen = await _pickCategory(collected);
                                if (chosen == null) return; // User cancelled

                                final category = chosen;
                                // Create updated card with category
                                final updatedCard =
                                    collected.copyWith(category: category);
                                // Preserve backend identifiers so update works
                                updatedCard.backendId = collected.backendId;
                                updatedCard.id = collected.id;
                                updatedCard.shareableId = collected.shareableId;
                                await context
                                    .read<CardCubit>()
                                    .updateCard(updatedCard);

                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content:
                                          Text('Card collected as "$category"'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                  // Redirect to home page
                                  Navigator.of(context).pushNamedAndRemoveUntil(
                                    AppRoutes.home,
                                    (route) => false,
                                  );
                                }
                              }
                            }
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error: ${e.toString()}'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        } finally {
                          if (mounted) {
                            setState(() {
                              _isLoadingCard = false;
                            });
                          }
                        }
                      },
                child: _isLoadingCard
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        l10n.enter,
                        style: AppTextStyles.buttonPrimary(context),
                      ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            buildDivider(context),
            const SizedBox(height: AppSpacing.lg),
            Text(
              AppLocalizations.of(context)!.fillCardManually,
              style: AppTextStyles.heading3(context),
            ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(AppRoutes.fillCardManually);
                },
                child: Text(
                  AppLocalizations.of(context)!.fillManually,
                  style: AppTextStyles.buttonSecondary(context),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            buildDivider(context),
            const SizedBox(height: AppSpacing.lg),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: _pickImageFromGallery,
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.image,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.scanCard);
                  },
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.qr_code_scanner,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }
}
