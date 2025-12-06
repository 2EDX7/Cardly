import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import "package:cardly/presentation/theme/spacing.dart";
import "package:cardly/presentation/theme/typography.dart";
import '../../../../logic/cubits/language/language_cubit.dart';
import '../../../../logic/cubits/language/language_state.dart';
import 'package:cardly/src/generated/l10n/app_localizations.dart';

class LanguagesectionWidget extends StatefulWidget {
  const LanguagesectionWidget({super.key});

  @override
  State<LanguagesectionWidget> createState() => _LanguagesectionWidgetState();
}

class _LanguagesectionWidgetState extends State<LanguagesectionWidget> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.language,
          style: AppTextStyles.heading3(context).copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        BlocBuilder<LanguageCubit, LanguageState>(
          builder: (context, languageState) {
            final currentLocale = languageState.locale.languageCode;
            
            return Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: theme.colorScheme.outline.withOpacity(0.2),
                ),
              ),
              child: Column(
                children: [
                  // English Option
                  ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: currentLocale == 'en' 
                          ? theme.colorScheme.primary.withOpacity(0.1)
                          : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Text(
                          '🇬🇧',
                          style:  TextStyle(fontSize: 24),
                        ),
                      ),
                    ),
                    title: Text(
                      'English',
                      style: AppTextStyles.body(context).copyWith(
                        fontWeight: currentLocale == 'en' ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    trailing: currentLocale == 'en'
                      ? Icon(
                          Icons.check_circle,
                          color: theme.colorScheme.primary,
                        )
                      : null,
                    onTap: () {
                      context.read<LanguageCubit>().setEnglish();
                    },
                  ),
                  
                  Divider(height: 1, color: theme.colorScheme.outline.withOpacity(0.2)),
                  
                  // French Option
                  ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: currentLocale == 'fr' 
                          ? theme.colorScheme.primary.withOpacity(0.1)
                          : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Text(
                          '🇫🇷',
                          style: TextStyle(fontSize: 24),
                        ),
                      ),
                    ),
                    title: Text(
                      'Français',
                      style: AppTextStyles.body(context).copyWith(
                        fontWeight: currentLocale == 'fr' ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    trailing: currentLocale == 'fr'
                      ? Icon(
                          Icons.check_circle,
                          color: theme.colorScheme.primary,
                        )
                      : null,
                    onTap: () {
                      context.read<LanguageCubit>().setFrench();
                    },
                  ),
                  
                  Divider(height: 1, color: theme.colorScheme.outline.withOpacity(0.2)),
                  
                  // Arabic Option
                  ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: currentLocale == 'ar' 
                          ? theme.colorScheme.primary.withOpacity(0.1)
                          : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Text(
                          '🇩🇿',
                          style:  TextStyle(fontSize: 24),
                        ),
                      ),
                    ),
                    title: Text(
                      'العربية',
                      style: AppTextStyles.body(context).copyWith(
                        fontWeight: currentLocale == 'ar' ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    trailing: currentLocale == 'ar'
                      ? Icon(
                          Icons.check_circle,
                          color: theme.colorScheme.primary,
                        )
                      : null,
                    onTap: () {
                      context.read<LanguageCubit>().setArabic();
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}