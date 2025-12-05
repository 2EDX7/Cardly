import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../logic/cubits/language/language_cubit.dart';
import '../../../logic/cubits/language/language_state.dart';
import 'package:cardly/presentation/theme/spacing.dart';
import 'package:cardly/presentation/theme/typography.dart';
import '../../src/generated/l10n/app_localizations.dart';

/// A widget that allows users to switch between languages
class LanguageSwitcher extends StatelessWidget {
  const LanguageSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return BlocBuilder<LanguageCubit, LanguageState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Text(
                l10n.selectLanguage,
                style: AppTextStyles.heading3(context),
              ),
            ),
            _LanguageTile(
              title: l10n.languageEnglish,
              subtitle: 'English',
              locale: const Locale('en'),
              isSelected: state.locale.languageCode == 'en',
              onTap: () {
                context.read<LanguageCubit>().setEnglish();
                Navigator.of(context).pop();
              },
            ),
            _LanguageTile(
              title: l10n.languageFrench,
              subtitle: 'Français',
              locale: const Locale('fr'),
              isSelected: state.locale.languageCode == 'fr',
              onTap: () {
                context.read<LanguageCubit>().setFrench();
                Navigator.of(context).pop();
              },
            ),
            _LanguageTile(
              title: l10n.languageArabic,
              subtitle: 'العربية',
              locale: const Locale('ar'),
              isSelected: state.locale.languageCode == 'ar',
              onTap: () {
                context.read<LanguageCubit>().setArabic();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  /// Show language switcher bottom sheet
  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.md),
        ),
      ),
      builder: (context) => const LanguageSwitcher(),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final Locale locale;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageTile({
    required this.title,
    required this.subtitle,
    required this.locale,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return ListTile(
      title: Text(
        title,
        style: AppTextStyles.body(context).copyWith(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: AppTextStyles.bodySmall(context),
      ),
      trailing: isSelected
          ? Icon(
              Icons.check_circle,
              color: theme.colorScheme.primary,
            )
          : null,
      onTap: onTap,
    );
  }
}
