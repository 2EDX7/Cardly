import 'package:flutter/material.dart';
import 'package:cardly/widgets/buildTextField.dart';
import '../widgets/navBar.dart';
class FillCardInformationScreen extends StatefulWidget {
  const FillCardInformationScreen({Key? key}) : super(key: key);

  @override
  State<FillCardInformationScreen> createState() => _FillCardInformationScreenState();
}

class _FillCardInformationScreenState extends State<FillCardInformationScreen> {
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
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F8F8),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Fill Card information',
          style: TextStyle(
            color: Colors.black,
            fontSize: 19,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  buildTextField('Full Name', _fullNameController),
                  buildTextField('Email', _emailController),
                  buildTextField('Phone', _phoneController),
                  buildTextField('Company', _companyController),
                  buildTextField('Job Title', _jobTitleController),
                  buildTextField('Location', _locationController),
                  buildTextField('Website', _websiteController),
                  buildTextField('About', _aboutController),
                  const SizedBox(height: 24),
                  
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: (){},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6C63FF),
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Preview Card',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
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