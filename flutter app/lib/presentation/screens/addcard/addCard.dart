import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cardly/presentation/widgets/buildDivider.dart';
import 'package:cardly/presentation/theme/colors.dart';
import 'package:cardly/presentation/theme/spacing.dart';
import 'package:cardly/presentation/theme/typography.dart';
import 'package:cardly/routes/routes.dart';

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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Image selected: ${image.name}\nOCR processing coming soon!'),
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: $e'),
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Photo captured: ${image.name}\nOCR processing coming soon!'),
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error taking photo: $e'),
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
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        automaticallyImplyLeading: false, // Remove back button
        title: Text(
          'Add Card',
          style: AppTextStyles.heading3(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.paddingMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter the Card ID',
              style: AppTextStyles.heading2(context),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'If the business card is registered in our app',
              style: AppTextStyles.bodySmall(context).copyWith(color: AppColors.primary),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _cardIdController,
              decoration: const InputDecoration(
                hintText: 'Cardly Card ID',
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
                      const SnackBar(
                        content: Text('Please enter a Card ID'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                    return;
                  }
                  
                  // TODO: Implement API call to fetch card by ID
                  // For now, show a message that this feature is coming soon
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Looking up card ID: $cardId...\\nFeature coming soon!'),
                      backgroundColor: Theme.of(context).colorScheme.primary,
                    ),
                  );
                },
                child: Text(
                  'Enter',
                  style: AppTextStyles.buttonPrimary(context),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            buildDivider(context),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Fill The Card Manually',
              style: AppTextStyles.heading3(context),
            ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.fillCardManually);
                },
                child: Text(
                  'Fill Manually',
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
                  'Scan QR Code',
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
