import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cardly/presentation/widgets/buildDivider.dart';
import 'package:cardly/presentation/theme/colors.dart';
import 'package:cardly/presentation/theme/spacing.dart';
import 'package:cardly/presentation/theme/typography.dart';
import 'package:cardly/routes/routes.dart';
import "../../../l10n/app_localizations.dart";
import '../../../logic/cubits/card/card_cubit.dart';
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
      
      if (image != null) {
        // TODO: Process the image with OCR to extract card information
        // For now, show a message that this feature is coming soon
        if (mounted) {
          final l10n = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${l10n.imageSelected(image.name)}\n${l10n.ocrProcessingComingSoon}'),
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
          );
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

  Future<void> _pickImageFromCamera() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );
      
      if (image != null) {
        // TODO: Process the image with OCR to extract card information
        // For now, show a message that this feature is coming soon
        if (mounted) {
          final l10n = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${l10n.photoCaptured(image.name)}\n${l10n.ocrProcessingComingSoon}'),
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.errorTakingPhoto(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
              AppLocalizations.of(context)!.enterCardId,
              style: AppTextStyles.heading2(context),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              AppLocalizations.of(context)!.cardRegisteredInApp,
              style: AppTextStyles.bodySmall(context).copyWith(color: AppColors.primary),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _cardIdController,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.cardlyCardId,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoadingCard ? null : () async {
                  final cardId = _cardIdController.text.trim();
                  if (cardId.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(l10n.errorCardIdEmpty),
                        backgroundColor: Colors.orange,
                      ),
                    );
                    return;
                  }
                  
                  final id = int.tryParse(cardId);
                  if (id == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Invalid card ID. Please enter a number.'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  setState(() {
                    _isLoadingCard = true;
                  });

                  try {
                    // Fetch card by ID
                    final card = await context.read<CardCubit>().fetchCardByIdGlobal(id);

                    if (!mounted) return;

                    if (card == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Card not found with ID: $cardId'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    } else {
                      // Show preview dialog
                      final shouldAdd = await _showCardPreview(card);
                      
                      if (shouldAdd == true && mounted) {
                        // Add card to collection
                        await context.read<CardCubit>().addCard(card);
                        
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Card added: ${card.name}'),
                              backgroundColor: Colors.green,
                            ),
                          );
                          _cardIdController.clear();
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
                  onTap: _pickImageFromCamera,
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.scanCard);
                },
                icon: const Icon(
                  Icons.qr_code_scanner,
                  size: 20,
                ),
                label: Text(
                  l10n.scanQrCode,
                  style: AppTextStyles.buttonSecondary(context),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }
}
