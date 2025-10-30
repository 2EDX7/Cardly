import 'package:flutter/material.dart';
import 'package:cardly/widgets/buildTextField.dart';
import 'package:cardly/widgets/navBar.dart' ;
import 'package:cardly/theme/spacing.dart';
import 'package:cardly/theme/typography.dart';
class Fillcardinformations extends StatefulWidget {
  const Fillcardinformations({Key? key}) : super(key: key);

  @override
  State<Fillcardinformations> createState() => _FillcardinformationsState();
}

class _FillcardinformationsState extends State<Fillcardinformations> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _companyController = TextEditingController();
  final TextEditingController _jobTitleController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();
  final TextEditingController _aboutController = TextEditingController();
  
  int _activeNavIndex = 1;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _companyController.dispose();
    _jobTitleController.dispose();
    _locationController.dispose();
    _websiteController.dispose();
    _aboutController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Fill Card Informations',
          style: AppTextStyles.heading3(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: AppSpacing.paddingLg,
              child: Column(
                children: [
                  buildTextField(context, 'Full Name', _fullNameController),
                  buildTextField(context, 'Email', _emailController),
                  buildTextField(context, 'Phone', _phoneController),
                  buildTextField(context, 'Company', _companyController),
                  buildTextField(context, 'Job Title', _jobTitleController),
                  buildTextField(context, 'Location', _locationController),
                  buildTextField(context, 'Website', _websiteController),
                  buildTextField(context, 'About', _aboutController),
                  const SizedBox(height: 24),
                  
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: (){},
                      child: Text(
                        'Preview Card',
                        style: AppTextStyles.buttonPrimary(context),
                      ),
                    ),
                  ),
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