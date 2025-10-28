import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'colors.dart';
import 'spacing.dart';
import 'typography.dart';
import 'theme_modifier.dart';

/// 🎨 Design System Demonstration Screen
/// 
/// This widget showcases all the design system components:
/// - Colors (brand, status, background)
/// - Typography (headings, body, captions)
/// - Spacing/Padding system
/// - Button styles
/// - Theme toggling functionality
/// 
/// Use this as a reference for how to use the design system in your implementations
/// 
/// 💡 TIP FOR TEAMMATES:
/// To test different spacing values, simply change the parameters passed to:
/// - _buildPaddingExample(AppSpacing.lg, context)  // Change AppSpacing.lg to any value
/// - _buildMarginExample(AppSpacing.md, context)   // Change AppSpacing.md to any value

class ThemeDemonstration extends StatelessWidget {
  const ThemeDemonstration({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final themeModifier = Provider.of<ThemeModifier>(context);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text('Cardly Design System', style: AppTextStyles.body(context)),
        elevation: 0,
        actions: [
          // 🌓 Dark/Light Mode Toggle Button
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.md),
            child: Center(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => themeModifier.toggleTheme(),
                  borderRadius: BorderRadius.circular(50),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    child: Icon(
                      themeModifier.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                      color: colorScheme.onPrimary,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 📌 HEADER SECTION
              _buildSectionHeader('Cardly App Design System', context),
              const SizedBox(height: AppSpacing.xxl),

              // 📌 TYPOGRAPHY SHOWCASE
              _buildSectionHeader('Typography Styles', context),
              const SizedBox(height: AppSpacing.md),
              _buildTypographyShowcase(context),
              const SizedBox(height: AppSpacing.xl),

              // 📌 SPACING SHOWCASE
              _buildSectionHeader('Spacing System', context),
              const SizedBox(height: AppSpacing.md),
              _buildSpacingShowcase(context),
              const SizedBox(height: AppSpacing.xl),

              // 📌 COLORS SHOWCASE
              _buildSectionHeader('Color Palette', context),
              const SizedBox(height: AppSpacing.md),
              _buildColorShowcase(context),
              const SizedBox(height: AppSpacing.xl),

              // 📌 BUTTONS SHOWCASE
              _buildSectionHeader('Button Styles', context),
              const SizedBox(height: AppSpacing.md),
              _buildButtonShowcase(context),
              const SizedBox(height: AppSpacing.xl),

              // 📌 THEME TOGGLE INFO
              _buildThemeToggleInfo(context, themeModifier),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // 🎨 HELPER WIDGETS
  // ============================================================

  /// Section header widget
  Widget _buildSectionHeader(String title, BuildContext context) {
    return Text(
      title,
      style: AppTextStyles.heading1(context),
    );
  }

  /// Typography showcase widget
  Widget _buildTypographyShowcase(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.onSurface.withAlpha(25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Heading 1', style: AppTextStyles.heading1(context)),
          const SizedBox(height: AppSpacing.sm),
          Text('Heading 2', style: AppTextStyles.heading2(context)),
          const SizedBox(height: AppSpacing.sm),
          Text('Heading 3', style: AppTextStyles.heading3(context)),
          const SizedBox(height: AppSpacing.md),
          Text('Body Large', style: AppTextStyles.bodyLarge(context)),
          const SizedBox(height: AppSpacing.sm),
          Text('Body Regular', style: AppTextStyles.body(context)),
          const SizedBox(height: AppSpacing.sm),
          Text('Body Small', style: AppTextStyles.bodySmall(context)),
          const SizedBox(height: AppSpacing.md),
          Text('Caption Style', style: AppTextStyles.caption(context)),
          const SizedBox(height: AppSpacing.md),
          Text('Link Style', style: AppTextStyles.linkText(context).copyWith(color: AppColors.primary)),
          // use copWith to use the default designs stated in the design system and override what you want.
          const SizedBox(height: AppSpacing.sm),
          Text('OVERLINE TEXT', style: AppTextStyles.overline(context)),
        ],
      ),
    );
  }

  /// Spacing system showcase widget
  Widget _buildSpacingShowcase(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.onSurface.withAlpha(25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSpacingRow('XS', AppSpacing.xs, context),
          _buildSpacingRow('SM', AppSpacing.sm, context),
          _buildSpacingRow('MD', AppSpacing.md, context),
          _buildSpacingRow('LG', AppSpacing.lg, context),
          _buildSpacingRow('XL', AppSpacing.xl, context),
          _buildSpacingRow('XXL', AppSpacing.xxl, context),
          const SizedBox(height: AppSpacing.xl),
          Text(
            'Padding & Margin Examples:',
            style: AppTextStyles.bodySmall(context),
          ),
          const SizedBox(height: AppSpacing.sm),
          // 💡 CHANGE THE PARAMETERS BELOW TO TEST DIFFERENT SPACING VALUES
          // Example: Change AppSpacing.lg to AppSpacing.sm or AppSpacing.xxl
          _buildPaddingExample(AppSpacing.lg, context),
          const SizedBox(height: AppSpacing.md),
          _buildMarginExample(AppSpacing.md, context),
        ],
      ),
    );
  }

  /// Individual spacing row widget
  Widget _buildSpacingRow(String label, double value, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          SizedBox(
            width: 50,
            child: Text(
              label,
              style: AppTextStyles.bodySmall(context),
            ),
          ),
          Container(
            height: 20,
            width: value,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            '${value.toStringAsFixed(0)}px',
            style: AppTextStyles.caption(context),
          ),
        ],
      ),
    );
  }

  /// Padding Example With Spacing System
  Widget _buildPaddingExample(double padding, BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withAlpha(200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Container(
          height: 60,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withAlpha(100),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            "Inner Content (Padding: ${padding.toStringAsFixed(0)}px)",
            style: AppTextStyles.bodySmall(context).copyWith(
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
        ),
      ),
    );
  }

  /// Margin Example With Spacing System
  Widget _buildMarginExample(double margin, BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.secondary.withAlpha(63),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Container(
        margin: EdgeInsets.all(margin),
        height: 60,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary.withAlpha(200),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          "Inner Box (Margin: ${margin.toStringAsFixed(0)}px)",
          style: AppTextStyles.bodySmall(context).copyWith(
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
      ),
    );
  }

  /// Color palette showcase widget
  Widget _buildColorShowcase(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.md,
      children: [
        _buildColorBox('Primary', AppColors.primary, context),
        _buildColorBox('Primary Light', AppColors.primaryLight, context),
        _buildColorBox('Primary Dark', AppColors.primaryDark, context),
        _buildColorBox('Secondary', AppColors.secondary, context),
        _buildColorBox('Success', AppColors.success, context),
        _buildColorBox('Error', AppColors.error, context),
        _buildColorBox('Warning', AppColors.warning, context),
      ],
    );
  }

  /// Individual color box widget
  Widget _buildColorBox(String label, Color color, BuildContext context) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Theme.of(context).colorScheme.onSurface.withAlpha(25),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          label,
          style: AppTextStyles.caption(context),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// Button styles showcase widget
  Widget _buildButtonShowcase(BuildContext context) {
    return Column(
      spacing: AppSpacing.md,
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {},
            child: Text(
              'Primary Button',
              style: AppTextStyles.buttonPrimary(context),
            ),
          ),
        ),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () {},
            child: Text(
              'Secondary Button',
              style: AppTextStyles.buttonSecondary(context),
            ),
          ),
        ),
      ],
    );
  }

  /// Theme toggle status and button widget
  Widget _buildThemeToggleInfo(BuildContext context, ThemeModifier themeModifier) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.onSurface.withAlpha(25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🌓 Theme Status',
            style: AppTextStyles.heading3(context),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Current Mode: ${themeModifier.isDarkMode ? '🌙 Dark Mode' : '☀️ Light Mode'}',
            style: AppTextStyles.body(context),
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => Provider.of<ThemeModifier>(context, listen: false).toggleTheme(),
              icon: Icon(themeModifier.isDarkMode ? Icons.light_mode : Icons.dark_mode),
              label: Text(
                'Toggle Theme',
                style: AppTextStyles.buttonPrimary(context),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '✨ Tap the icon in the AppBar or the button below to switch between themes!',
            style: AppTextStyles.caption(context),
          ),
        ],
      ),
    );
  }
}