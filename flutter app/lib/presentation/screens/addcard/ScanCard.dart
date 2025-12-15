import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:cardly/presentation/widgets/navBar.dart';
import 'package:cardly/presentation/theme/spacing.dart';
import 'package:cardly/presentation/theme/typography.dart';
import '../../../l10n/app_localizations.dart';
import '../../../data/models/card_info.dart';
import '../../../logic/cubits/card/card_cubit.dart';

class ScanCardScreen extends StatefulWidget {
  const ScanCardScreen({Key? key}) : super(key: key);

  @override
  State<ScanCardScreen> createState() => _ScanCardScreenState();
}

class _ScanCardScreenState extends State<ScanCardScreen> {
  int _activeNavIndex = 1;
  bool _isScanning = false;
  bool _hasScanned = false;
  MobileScannerController? _cameraController;
  
  // For Add by ID functionality
  final TextEditingController _idController = TextEditingController();
  CardInfo? _previewCard;
  bool _isLoadingId = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _cameraController = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
    );
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _idController.dispose();
    super.dispose();
  }

  void _handleScan() {
    setState(() {
      _isScanning = true;
      _previewCard = null;
      _errorMessage = null;
    });
  }

  Future<void> _fetchCardById() async {
    final idText = _idController.text.trim();
    if (idText.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter a card ID';
      });
      return;
    }

    final id = int.tryParse(idText);
    if (id == null) {
      setState(() {
        _errorMessage = 'Invalid card ID. Please enter a number';
      });
      return;
    }

    setState(() {
      _isLoadingId = true;
      _errorMessage = null;
      _previewCard = null;
      _isScanning = false;
    });

    try {
      final card = await context.read<CardCubit>().fetchCardByIdGlobal(id);

      if (card == null) {
        if (mounted) {
          setState(() {
            _errorMessage = 'Card not found with ID: $id';
            _isLoadingId = false;
          });
        }
        return;
      }

      if (mounted) {
        setState(() {
          _previewCard = card;
          _isLoadingId = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error fetching card: ${e.toString()}';
          _isLoadingId = false;
        });
      }
    }
  }

  Future<void> _addCardFromPreview() async {
    if (_previewCard == null) return;

    try {
      await context.read<CardCubit>().addCard(_previewCard!);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Card added: ${_previewCard!.name}'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error adding card: ${e.toString()}';
        });
      }
    }
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_hasScanned) return;

    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      final String? code = barcode.rawValue;
      if (code != null && code.isNotEmpty) {
        _hasScanned = true;
        
        try {
          // Parse the JSON data from QR code
          final Map<String, dynamic> cardData = jsonDecode(code);
          final CardInfo scannedCard = CardInfo.fromJson(cardData);

          // Add the card using cubit
          if (mounted) {
            await context.read<CardCubit>().addCard(scannedCard);
            
            // Show success message
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Card added: ${scannedCard.name}'),
                  backgroundColor: Colors.green,
                ),
              );
              
              // Go back after successful scan
              Navigator.pop(context, true);
            }
          }
        } catch (e) {
          // Show error if QR code is invalid
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Invalid QR code: ${e.toString()}'),
                backgroundColor: Colors.red,
              ),
            );
            setState(() {
              _hasScanned = false;
            });
          }
        }
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: Theme.of(context).colorScheme.onBackground),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l10n.scanCard,
          style: AppTextStyles.heading3(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: AppSpacing.paddingMd,
              child: Column(
                children: [
                  SizedBox(height: AppSpacing.md),

                  // Camera/QR Scanner Area
                  Container(
                    width: double.infinity,
                    height: 340,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.onBackground.withAlpha(230),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          if (!_isScanning)
                            Container(
                              width: 220,
                              height: 220,
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surface,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.qr_code_2,
                                  size: 180,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                            ),

                          if (_isScanning)
                            MobileScanner(
                              controller: _cameraController,
                              onDetect: _onDetect,
                            ),

                          if (_isScanning)
                            Container(
                              width: 220,
                              height: 220,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Theme.of(context).colorScheme.primary,
                                  width: 3,
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),

                          if (_isScanning)
                            Positioned(
                              top: 16,
                              right: 16,
                              child: IconButton(
                                onPressed: () {
                                  _cameraController?.toggleTorch();
                                },
                                icon: Icon(
                                  Icons.flash_on,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                style: IconButton.styleFrom(
                                  backgroundColor: Colors.black54,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: AppSpacing.lg),

                  Text(
                    l10n.pointCameraAtCard,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodySmall(context),
                  ),

                  SizedBox(height: AppSpacing.xl),

                  // Divider with "OR" text
                  Row(
                    children: [
                      Expanded(child: Divider(color: cs.onSurfaceVariant.withOpacity(0.3))),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                        child: Text(
                          'OR',
                          style: AppTextStyles.bodySmall(context).copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ),
                      Expanded(child: Divider(color: cs.onSurfaceVariant.withOpacity(0.3))),
                    ],
                  ),

                  SizedBox(height: AppSpacing.lg),

                  // Add by ID Section
                  Text(
                    'Enter Card ID',
                    style: AppTextStyles.heading3(context),
                  ),
                  
                  SizedBox(height: AppSpacing.md),

                  // ID Input Field
                  TextField(
                    controller: _idController,
                    decoration: InputDecoration(
                      labelText: 'Card ID',
                      hintText: 'Enter card ID',
                      prefixIcon: const Icon(Icons.numbers),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: _fetchCardById,
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onSubmitted: (_) => _fetchCardById(),
                  ),

                  SizedBox(height: AppSpacing.md),

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
                          const Icon(Icons.error_outline, color: Colors.red, size: 20),
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
                  if (_isLoadingId)
                    const Padding(
                      padding: EdgeInsets.all(AppSpacing.lg),
                      child: CircularProgressIndicator(),
                    ),

                  // Card Preview
                  if (_previewCard != null) ...[
                    SizedBox(height: AppSpacing.md),
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
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    Text(
                                      _previewCard!.jobTitle,
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                            color: cs.onSurfaceVariant,
                                          ),
                                    ),
                                    Text(
                                      _previewCard!.organization,
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
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
                          _InfoItem(icon: Icons.location_on, text: _previewCard!.location),
                        ],
                      ),
                    ),
                    SizedBox(height: AppSpacing.md),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _addCardFromPreview,
                        icon: const Icon(Icons.add),
                        label: const Text('Add to My Cards'),
                      ),
                    ),
                  ],

                  SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          ),

          SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isScanning ? null : _handleScan,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.camera_alt,
                          size: 19,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _isScanning ? l10n.scanning : l10n.scan,
                        style: AppTextStyles.buttonPrimary(context),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          BottomNavBar(
            activeIndex: _activeNavIndex,
            onTabChange: (index) {
              setState(() {
                _activeNavIndex = index;
              });
            },
          ),
        ],
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


