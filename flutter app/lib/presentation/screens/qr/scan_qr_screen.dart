import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/card_info.dart';
import '../../theme/spacing.dart';
import '../../../logic/cubits/card/card_cubit.dart';

class ScanQrScreen extends StatefulWidget {
  const ScanQrScreen({super.key});

  @override
  State<ScanQrScreen> createState() => _ScanQrScreenState();
}

class _ScanQrScreenState extends State<ScanQrScreen> {
  MobileScannerController cameraController = MobileScannerController();
  bool _isProcessing = false;

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
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
          // Use the cubit to collect properly
          await context.read<CardCubit>().collectCardByShareableId(rawValue);
          
          if (mounted) {
             ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Card collected successfully!'),
                backgroundColor: Colors.green,
              ),
            );
            // Return null or true to indicate handled
            Navigator.pop(context, true);
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
