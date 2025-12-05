import 'package:flutter/material.dart';
import 'package:cardly/presentation/theme/spacing.dart';
import 'package:cardly/presentation/theme/typography.dart';
import 'package:cardly/data/models/card_info.dart';
import '../../../src/generated/l10n/app_localizations.dart';
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
      final updatedCardInfo = widget.cardInfo.copyWith(
        name: _nameController.text,
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
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onBackground),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          l10n.editCard,
          style: AppTextStyles.heading2(context).copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onBackground,
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
                l10n.personalInformation,
                style: AppTextStyles.overline(context).copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onBackground,
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              _buildTextField(
                controller: _nameController,
                labelText: l10n.fullName,
                hintText: l10n.enterYourFullName,
                prefixIcon: Icons.person_outline,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l10n.pleaseEnterYourName;
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.md),

              _buildTextField(
                controller: _jobTitleController,
                labelText: l10n.jobTitle,
                hintText: l10n.enterYourJobTitle,
                prefixIcon: Icons.work_outline,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l10n.pleaseEnterYourJobTitle;
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.lg),

              // Organization Section
              Text(
                l10n.organizationSection,
                style: AppTextStyles.overline(context).copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onBackground,
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              _buildTextField(
                controller: _organizationController,
                labelText: l10n.organizationName,
                hintText: l10n.enterOrganizationName,
                prefixIcon: Icons.business_outlined,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l10n.pleaseEnterOrganizationName;
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
                l10n.contactInformation,
                style: AppTextStyles.overline(context).copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onBackground,
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              _buildTextField(
                controller: _emailController,
                labelText: l10n.email,
                hintText: l10n.enterYourEmail,
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l10n.pleaseEnterEmail;
                  }
                  if (!value.contains('@')) {
                    return l10n.pleaseEnterValidEmail;
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.md),

              _buildTextField(
                controller: _phoneController,
                labelText: l10n.phone,
                hintText: l10n.enterYourPhone,
                prefixIcon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l10n.pleaseEnterYourPhoneNumber;
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.md),

              _buildTextField(
                controller: _locationController,
                labelText: l10n.location,
                hintText: l10n.enterYourLocation,
                prefixIcon: Icons.location_on_outlined,
              ),
              const SizedBox(height: AppSpacing.md),

              _buildTextField(
                controller: _websiteController,
                labelText: l10n.website,
                hintText: l10n.enterYourWebsite,
                prefixIcon: Icons.language_outlined,
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: AppSpacing.lg),

              // About Section
              Text(
                l10n.aboutSection,
                style: AppTextStyles.overline(context).copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onBackground,
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              _buildTextField(
                controller: _aboutController,
                labelText: l10n.about,
                hintText: l10n.tellUsAboutYourself,
                prefixIcon: Icons.info_outline,
                maxLines: 4,
              ),
              const SizedBox(height: AppSpacing.xxl),

              // Save Button
              SizedBox(
                width: double.infinity,
                // height: 56,
                child: ElevatedButton(
                  onPressed: _saveChanges,
                  child: Text(
                    l10n.saveChanges,
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
