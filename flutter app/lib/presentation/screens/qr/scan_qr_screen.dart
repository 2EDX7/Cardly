import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/card_info.dart';
import '../../theme/spacing.dart';
import '../../../logic/cubits/card/card_cubit.dart';
import '../../../logic/cubits/card/card_state.dart';
import '../../../l10n/app_localizations.dart';
import '../../../routes/routes.dart';

class ScanQrScreen extends StatefulWidget {
  const ScanQrScreen({super.key});

  @override
  State<ScanQrScreen> createState() => _ScanQrScreenState();
}

class _ScanQrScreenState extends State<ScanQrScreen> {
  MobileScannerController cameraController = MobileScannerController();
  bool _isProcessing = false;
  final TextEditingController _newCategoryController = TextEditingController();

  @override
  void dispose() {
    cameraController.dispose();
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
              title: Text('Select Category'),
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
                            if (!creating) {
                              _newCategoryController.clear();
                            }
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

  void _onDetect(BarcodeCapture capture) async {
    if (_isProcessing) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final barcode = barcodes.first;
    final String? rawValue = barcode.rawValue;

    if (rawValue == null || rawValue.isEmpty) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      // Check if it's a JSON (legacy or offline) or a simple ID string
      if (rawValue.trim().startsWith('{')) {
        // Handle as JSON (fallback)
        try {
          final decodedMap = jsonDecode(rawValue) as Map<String, dynamic>;
          final card = CardInfo.fromJson(decodedMap);
          if (mounted) {
            Navigator.pop(context, card);
          }
        } catch (e) {
          throw Exception('Invalid card data format');
        }
      } else {
        // Assume it's a shareable ID - Collect via API
        if (mounted) {
          final collected = await context
              .read<CardCubit>()
              .collectCardByShareableId(rawValue);

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
        String errorMessage = 'Error scanning: ${e.toString()}';

        // Improve error message if it's from our API Exceptions
        if (e.toString().contains('Card not found')) {
          errorMessage = 'Card not found with this ID';
        } else if (e.toString().contains('already collected')) {
          errorMessage = 'You have already collected this card';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );

        // Wait a bit before processing again to avoid rapid-fire errors
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          setState(() {
            _isProcessing = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Card'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on),
            onPressed: () => cameraController.toggleTorch(),
          ),
          IconButton(
            icon: const Icon(Icons.cameraswitch),
            onPressed: () => cameraController.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: cameraController,
            onDetect: _onDetect,
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              color: Colors.black54,
              child: const Text(
                'Point your camera at a business card QR code',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          if (_isProcessing)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}
