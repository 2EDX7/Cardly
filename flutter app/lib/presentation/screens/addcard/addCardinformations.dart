import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cardly/src/generated/l10n/app_localizations.dart';
import 'package:cardly/presentation/widgets/buildTextField.dart';
import 'package:cardly/presentation/theme/spacing.dart';
import 'package:cardly/presentation/theme/typography.dart';
import 'package:cardly/data/models/card_info.dart';
import '../../../logic/cubits/card/card_cubit.dart';
import '../../../logic/cubits/card/card_state.dart';

class Addcardinformations extends StatefulWidget {
  const Addcardinformations({Key? key}) : super(key: key);

  @override
  State<Addcardinformations> createState() => _AddcardinformationsState();
}

class _AddcardinformationsState extends State<Addcardinformations> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _companyController = TextEditingController();
  final TextEditingController _jobTitleController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();
  final TextEditingController _aboutController = TextEditingController();
  String? _selectedCategory;
  
  final List<String> _categories = [
    'Technology',
    'Business',
    'Healthcare',
    'Education',
    'Finance',
    'Marketing',
    'Design',
    'Engineering',
    'Other',
  ];

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
    final l10n = AppLocalizations.of(context)!;
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
          l10n.addCard,
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
                  buildTextField(context, l10n.fullName, _fullNameController),
                  buildTextField(context, l10n.email, _emailController),
                  buildTextField(context, l10n.phone, _phoneController),
                  buildTextField(context, l10n.company, _companyController),
                  buildTextField(context, l10n.jobTitle, _jobTitleController),
                  buildTextField(context, l10n.location, _locationController),
                  buildTextField(context, l10n.website, _websiteController),
                  buildTextField(context, l10n.about, _aboutController),
                  
                  // Category Dropdown
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    decoration: InputDecoration(
                      labelText: l10n.categoryOptional,
                      labelStyle: TextStyle(
                        color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.onBackground.withOpacity(0.3),
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
                    items: _categories.map((String category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedCategory = newValue;
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  
                  BlocConsumer<CardCubit, CardState>(
                    listener: (context, state) {
                        if (state is CardAdded) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(AppLocalizations.of(context)!.cardAddedSuccessfully),
                              backgroundColor: Colors.green,
                            ),
                          );
                        Navigator.pop(context);
                      } else if (state is CardError) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(state.message),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    builder: (context, state) {
                      final isLoading = state is CardLoading;
                      
                      return SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : () {
                            // Validate required fields
                            if (_fullNameController.text.isEmpty ||
                                _emailController.text.isEmpty ||
                                _phoneController.text.isEmpty ||
                                _companyController.text.isEmpty ||
                                _jobTitleController.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(l10n.pleaseFillAllRequiredFields),
                                  backgroundColor: Colors.orange,
                                ),
                              );
                              return;
                            }

                            final newCard = CardInfo(
                              name: _fullNameController.text,
                              email: _emailController.text,
                              phone: _phoneController.text,
                              organization: _companyController.text,
                              jobTitle: _jobTitleController.text,
                              location: _locationController.text,
                              website: _websiteController.text,
                              about: _aboutController.text,
                              category: _selectedCategory ?? l10n.uncategorized,
                            );

                            context.read<CardCubit>().addCard(newCard);
                          },
                          child: isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : Text(
                                  l10n.addCard,
                                  style: AppTextStyles.buttonPrimary(context),
                                ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],  
      ),
    );
  }
}