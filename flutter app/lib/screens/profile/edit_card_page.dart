import 'package:flutter/material.dart';
import 'package:cardly/theme/colors.dart';
import 'package:cardly/theme/spacing.dart';
import 'package:cardly/theme/typography.dart';

/// Model class to hold card information
class CardInfo {
  String name;
  // String logoText;
  String organization;
  String jobTitle;
  String email;
  String phone;
  String location;
  String about;
  String website;

  CardInfo({
    required this.name,
    // required this.logoText,
    required this.organization,
    required this.jobTitle,
    required this.email,
    required this.phone,
    required this.location,
    required this.about,
    required this.website,
  });

  CardInfo copyWith({
    String? name,
    // String? logoText,
    String? organization,
    String? jobTitle,
    String? email,
    String? phone,
    String? location,
    String? about,
    String? website,
  }) {
    return CardInfo(
      name: name ?? this.name,
      // logoText: logoText ?? this.logoText,
      organization: organization ?? this.organization,
      jobTitle: jobTitle ?? this.jobTitle,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      location: location ?? this.location,
      about: about ?? this.about,
      website: website ?? this.website,
    );
  }
}

/// Edit card page where user can update card information
class EditCardPage extends StatefulWidget {
  final CardInfo cardInfo;

  const EditCardPage({
    super.key,
    required this.cardInfo,
  });

  @override
  State<EditCardPage> createState() => _EditCardPageState();
}

class _EditCardPageState extends State<EditCardPage> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameController;
  // late TextEditingController _logoTextController;
  late TextEditingController _organizationController;
  late TextEditingController _jobTitleController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _locationController;
  late TextEditingController _aboutController;
  late TextEditingController _websiteController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.cardInfo.name);
    // _logoTextController = TextEditingController(text: widget.cardInfo.logoText);
    _organizationController = TextEditingController(text: widget.cardInfo.organization);
    _jobTitleController = TextEditingController(text: widget.cardInfo.jobTitle);
    _emailController = TextEditingController(text: widget.cardInfo.email);
    _phoneController = TextEditingController(text: widget.cardInfo.phone);
    _locationController = TextEditingController(text: widget.cardInfo.location);
    _aboutController = TextEditingController(text: widget.cardInfo.about);
    _websiteController = TextEditingController(text: widget.cardInfo.website);
  }

  @override
  void dispose() {
    _nameController.dispose();
    // _logoTextController.dispose();
    _organizationController.dispose();
    _jobTitleController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _aboutController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    if (_formKey.currentState!.validate()) {
      final updatedCardInfo = CardInfo(
        name: _nameController.text,
        // logoText: _logoTextController.text,
        organization: _organizationController.text,
        jobTitle: _jobTitleController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        location: _locationController.text,
        about: _aboutController.text,
        website: _websiteController.text,
      );

      Navigator.of(context).pop(updatedCardInfo);
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    required IconData prefixIcon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: AppTextStyles.body(context),
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon: Icon(prefixIcon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.md),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: AppColors.lightBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Edit Card',
          style: AppTextStyles.heading2(context).copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: AppSpacing.paddingLg,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Personal Information Section
              Text(
                'PERSONAL INFORMATION',
                style: AppTextStyles.overline(context).copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              _buildTextField(
                controller: _nameController,
                labelText: 'Full Name',
                hintText: 'Enter your full name',
                prefixIcon: Icons.person_outline,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.md),

              _buildTextField(
                controller: _jobTitleController,
                labelText: 'Job Title',
                hintText: 'Enter your job title',
                prefixIcon: Icons.work_outline,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your job title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.lg),

              // Organization Section
              Text(
                'ORGANIZATION',
                style: AppTextStyles.overline(context).copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              _buildTextField(
                controller: _organizationController,
                labelText: 'Organization Name',
                hintText: 'Enter organization name',
                prefixIcon: Icons.business_outlined,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter organization name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.md),

              // _buildTextField(
              //   controller: _logoTextController,
              //   labelText: 'Logo Text',
              //   hintText: 'Enter logo text (abbreviation)',
              //   prefixIcon: Icons.text_fields,
              // ),
              // const SizedBox(height: AppSpacing.lg),

              // Contact Information Section
              Text(
                'CONTACT INFORMATION',
                style: AppTextStyles.overline(context).copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              _buildTextField(
                controller: _emailController,
                labelText: 'Email',
                hintText: 'Enter your email',
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!value.contains('@')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.md),

              _buildTextField(
                controller: _phoneController,
                labelText: 'Phone',
                hintText: 'Enter your phone number',
                prefixIcon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.md),

              _buildTextField(
                controller: _locationController,
                labelText: 'Location',
                hintText: 'Enter your location',
                prefixIcon: Icons.location_on_outlined,
              ),
              const SizedBox(height: AppSpacing.md),

              _buildTextField(
                controller: _websiteController,
                labelText: 'Website',
                hintText: 'Enter your website',
                prefixIcon: Icons.language_outlined,
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: AppSpacing.lg),

              // About Section
              Text(
                'ABOUT',
                style: AppTextStyles.overline(context).copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              _buildTextField(
                controller: _aboutController,
                labelText: 'About',
                hintText: 'Tell us about yourself',
                prefixIcon: Icons.info_outline,
                maxLines: 4,
              ),
              const SizedBox(height: AppSpacing.xxl),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _saveChanges,
                  child: Text(
                    'Save Changes',
                    style: AppTextStyles.buttonPrimary(context).copyWith(
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}
