import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cardly/presentation/widgets/buildDivider.dart';
import 'package:cardly/presentation/theme/colors.dart';
import 'package:cardly/presentation/theme/spacing.dart';
import 'package:cardly/presentation/theme/typography.dart';
import 'package:cardly/routes/routes.dart';
import '../../../src/generated/l10n/app_localizations.dart';

class AddCardScreen extends StatefulWidget {
  const AddCardScreen({Key? key}) : super(key: key);

  @override
  State<AddCardScreen> createState() => _AddCardScreenState();
}

class _AddCardScreenState extends State<AddCardScreen> {
  final TextEditingController _cardIdController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();

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
                onPressed: () {
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
                  
                  // TODO: Implement API call to fetch card by ID
                  // For now, show a message that this feature is coming soon
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${l10n.lookingUpCardId(cardId)}\n${l10n.featureComingSoon}'),
                      backgroundColor: Theme.of(context).colorScheme.primary,
                    ),
                  );
                },
                child: Text(
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
