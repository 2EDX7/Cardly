import 'package:flutter/material.dart';
import 'package:cardly/widgets/navBar.dart';
import 'package:cardly/widgets/buildDivider.dart';
import 'package:cardly/theme/colors.dart';
import 'package:cardly/theme/spacing.dart';
import 'package:cardly/theme/typography.dart';
import 'package:cardly/screens/addcard/fillcardinformations.dart';
import 'package:cardly/screens/addcard/ScanCard.dart';
class AddCardScreen extends StatefulWidget {
  const AddCardScreen({Key? key}) : super(key: key);

  @override
  State<AddCardScreen> createState() => _AddCardScreenState();
}

class _AddCardScreenState extends State<AddCardScreen> {
  final TextEditingController _cardIdController = TextEditingController();
  int _activeNavIndex = 1;

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
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Add Card',
          style: AppTextStyles.heading3(context),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: AppSpacing.lg),
          Expanded(
            child: SingleChildScrollView(
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
                      onPressed: () {},
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
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const Fillcardinformations(),
                          ),
                        );
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
                        onTap: () {},
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
                        onTap: () {},
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
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ScanCardScreen(),
                          ),
                        );
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
