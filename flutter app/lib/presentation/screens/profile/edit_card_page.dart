import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cardly/presentation/theme/spacing.dart';
import 'package:cardly/presentation/theme/typography.dart';
import 'package:cardly/data/models/card_info.dart';
import 'package:cardly/data/models/user.dart';
import '../../../l10n/app_localizations.dart';
import '../../../logic/cubits/card/card_cubit.dart';
import '../../../logic/cubits/card/card_state.dart';

/// Edit card page where user can update card information
class EditCardPage extends StatefulWidget {
  final CardInfo cardInfo;
  final bool isProfileCard;
  final User? currentUser;

  const EditCardPage({
    super.key,
    required this.cardInfo,
    this.isProfileCard = false,
    this.currentUser,
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
  late TextEditingController _otherCategoryController;

  String? _selectedCategory;
  final Set<String> _customCategories = {};

  @override
  void initState() {
    super.initState();

    // Auto-fill name and email from user account if this is a new profile card
    String initialName = widget.cardInfo.name;
    String initialEmail = widget.cardInfo.email;

    if (widget.isProfileCard &&
        widget.currentUser != null &&
        widget.cardInfo.name.isEmpty) {
      initialName = widget.currentUser!.fullName;
      initialEmail = widget.currentUser!.email;
    }

    _nameController = TextEditingController(text: initialName);
    // _logoTextController = TextEditingController(text: widget.cardInfo.logoText);
    _organizationController =
        TextEditingController(text: widget.cardInfo.organization);
    _jobTitleController = TextEditingController(text: widget.cardInfo.jobTitle);
    _emailController = TextEditingController(text: initialEmail);
    _phoneController = TextEditingController(text: widget.cardInfo.phone);
    _locationController = TextEditingController(text: widget.cardInfo.location);
    _aboutController = TextEditingController(text: widget.cardInfo.about);
    _websiteController = TextEditingController(text: widget.cardInfo.website);
    _otherCategoryController = TextEditingController();
    _selectedCategory = widget.cardInfo.category;
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
    _otherCategoryController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    if (_formKey.currentState!.validate()) {
      // Determine final category (only for collected cards, not profile cards)
      String? finalCategory;

      if (!widget.isProfileCard) {
        finalCategory = _selectedCategory;
        if (_selectedCategory == 'Other') {
          final newCat = _otherCategoryController.text.trim();
          if (newCat.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Please enter a category name'),
                backgroundColor: Colors.orange,
              ),
            );
            return;
          }
          finalCategory = newCat;
          _customCategories.add(newCat);
        }
        finalCategory ??= AppLocalizations.of(context)!.uncategorized;
      }

      final updatedCardInfo = widget.cardInfo.copyWith(
        name: _nameController.text,
        organization: _organizationController.text,
        jobTitle: _jobTitleController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        location: _locationController.text,
        about: _aboutController.text,
        website: _websiteController.text,
        category: finalCategory,
      );
      // Preserve backend identifiers so update works for collected cards
      updatedCardInfo.backendId = widget.cardInfo.backendId;
      updatedCardInfo.id = widget.cardInfo.id;
      updatedCardInfo.shareableId = widget.cardInfo.shareableId;
      updatedCardInfo.isProfileCard = widget.cardInfo.isProfileCard;

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
    // Build category list from existing cards + custom selections
    final state = context.watch<CardCubit>().state;
    final existing = <String>{
      l10n.uncategorized,
      ..._customCategories,
    };

    if (state is CardLoaded) {
      existing.addAll(state.cards
          .map((c) => c.category ?? l10n.uncategorized)
          .where((c) => c.trim().isNotEmpty));
    }

    // Always include the current card's category if it exists
    if (widget.cardInfo.category != null &&
        widget.cardInfo.category!.trim().isNotEmpty) {
      existing.add(widget.cardInfo.category!);
    }

    // Always include the selected category if it exists and is not "Other"
    if (_selectedCategory != null &&
        _selectedCategory != 'Other' &&
        _selectedCategory!.trim().isNotEmpty) {
      existing.add(_selectedCategory!);
    }

    final categories = existing.toList()..sort();
    categories.add('Other');

    // Initialize _selectedCategory if null
    _selectedCategory ??= widget.cardInfo.category ?? l10n.uncategorized;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: Theme.of(context).colorScheme.onBackground),
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
              const SizedBox(height: AppSpacing.lg),

              // Category Section (only for collected cards, not profile cards)
              if (!widget.isProfileCard) ...[
                Text(
                  'Category',
                  style: AppTextStyles.overline(context).copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: InputDecoration(
                    labelText: l10n.categoryOptional,
                    labelStyle: TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .onBackground
                          .withOpacity(0.7),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Theme.of(context)
                            .colorScheme
                            .onBackground
                            .withOpacity(0.3),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                        width: 2,
                      ),
                    ),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surface,
                  ),
                  dropdownColor: Theme.of(context).colorScheme.surface,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onBackground,
                    fontSize: 16,
                  ),
                  items: categories.map((String category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedCategory = newValue;
                      if (newValue != 'Other') {
                        _otherCategoryController.clear();
                      }
                    });
                  },
                ),
                if (_selectedCategory == 'Other') ...[
                  const SizedBox(height: 12),
                  TextField(
                    controller: _otherCategoryController,
                    decoration: const InputDecoration(
                      labelText: 'New category name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ], // Close the if (!widget.isProfileCard) block

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
