import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../widgets/business_card/business_card.dart';
import '../../../widgets/business_card/card_background.dart';
import '../../../theme/spacing.dart';
import '../../../../data/models/card_info.dart';
import '../../../../l10n/app_localizations.dart';
import '../../qr/show_qr_code_screen.dart';

class CategorySection extends StatefulWidget {
  final String category;
  final List<CardInfo> cards;
  final bool isExpanded;
  final VoidCallback onToggle;
  final Function(CardInfo card)? onDeleteConfirmed;
  final Function(CardInfo card)? onEditTapped;
  final Function(CardInfo card)? onShareTapped;
  final AppLocalizations l10n;

  const CategorySection({
    super.key,
    required this.category,
    required this.cards,
    required this.isExpanded,
    required this.onToggle,
    required this.l10n,
    this.onDeleteConfirmed,
    this.onEditTapped,
    this.onShareTapped,
  });

  @override
  State<CategorySection> createState() => _CategorySectionState();
}

class _CategorySectionState extends State<CategorySection>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _iconRotation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _iconRotation = Tween<double>(
      begin: 0,
      end: 0.5,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    if (widget.isExpanded) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(CategorySection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isExpanded != oldWidget.isExpanded) {
      if (widget.isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category Header
        GestureDetector(
          onTap: widget.onToggle,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: Row(
              children: [
                RotationTransition(
                  turns: _iconRotation,
                  child: Icon(
                    Icons.arrow_drop_down,
                    color: Theme.of(context).colorScheme.onBackground,
                    size: 24,
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  widget.category,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
                ),
              ],
            ),
          ),
        ),
        // Category Cards with Animation
        ClipRect(
          child: AnimatedCrossFade(
            firstChild: Column(
              children:
                  widget.cards.map((card) => _buildCardItem(card)).toList(),
            ),
            secondChild: const SizedBox.shrink(),
            crossFadeState: widget.isExpanded
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            duration: const Duration(milliseconds: 200),
            sizeCurve: Curves.easeInOut,
          ),
        ),
      ],
    );
  }

  Widget _buildCardItem(CardInfo card) {
    // Import the _SwipeDeleteCard from home_page.dart would create circular dependency
    // So we recreate similar functionality here
    final cardIdKey = card.backendId ?? card.id?.toString() ?? card.email;

    return _CategorySwipeDeleteCard(
      key: Key(cardIdKey),
      card: card,
      cardIdKey: cardIdKey,
      onDeleteConfirmed: widget.onDeleteConfirmed != null
          ? () => widget.onDeleteConfirmed!(card)
          : () {},
      onEditTapped: widget.onEditTapped != null
          ? () => widget.onEditTapped!(card)
          : () {},
      onShareTapped: widget.onShareTapped != null
          ? () => widget.onShareTapped!(card)
          : () {},
      l10n: widget.l10n,
    );
  }
}

// Duplicate of _SwipeDeleteCard from home_page.dart for category view
class _CategorySwipeDeleteCard extends StatefulWidget {
  final CardInfo card;
  final String cardIdKey;
  final VoidCallback onDeleteConfirmed;
  final VoidCallback onEditTapped;
  final VoidCallback onShareTapped;
  final AppLocalizations l10n;

  const _CategorySwipeDeleteCard({
    required Key key,
    required this.card,
    required this.cardIdKey,
    required this.onDeleteConfirmed,
    required this.onEditTapped,
    required this.onShareTapped,
    required this.l10n,
  }) : super(key: key);

  @override
  State<_CategorySwipeDeleteCard> createState() =>
      _CategorySwipeDeleteCardState();
}

class _CategorySwipeDeleteCardState extends State<_CategorySwipeDeleteCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  double _dragOffset = 0;
  final double _deleteButtonWidth = 80;
  bool _isExpanded = false;
  DateTime _lastTap = DateTime.now();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    if (_isExpanded) return;
    setState(() {
      _dragOffset =
          (_dragOffset + details.delta.dx).clamp(-_deleteButtonWidth, 0);
    });
  }

  void _handleDragEnd(DragEndDetails details) {
    if (_isExpanded) return;
    final threshold = _deleteButtonWidth * 0.5;
    if (_dragOffset.abs() > threshold) {
      _animationController.forward();
      setState(() {
        _dragOffset = -_deleteButtonWidth;
      });
    } else {
      _animationController.reverse();
      setState(() {
        _dragOffset = 0;
      });
    }
  }

  void _showDeleteConfirmation() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(widget.l10n.deleteCard),
          content: Text(widget.l10n.areYouSureDeleteCard(widget.card.name)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(widget.l10n.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: Text(widget.l10n.delete),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      widget.onDeleteConfirmed();
      _animationController.reverse();
      setState(() {
        _dragOffset = 0;
      });
    }
  }

  void _handleCardTap() {
    final now = DateTime.now();
    final timeSinceLastTap = now.difference(_lastTap).inMilliseconds;
    _lastTap = now;

    if (timeSinceLastTap < 300) return;

    setState(() {
      _isExpanded = !_isExpanded;
      _dragOffset = 0;
    });
  }

  void _handleEdit() {
    widget.onEditTapped();
  }

  void _handleShare() {
    widget.onShareTapped();
  }

  Future<void> _handleCall() async {
    final phone = widget.card.phone;
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No phone number available')),
      );
      return;
    }

    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Cannot open phone app')),
        );
      }
    }
  }

  Future<void> _handleEmail() async {
    final email = widget.card.email;
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No email address available')),
      );
      return;
    }

    final uri = Uri(
      scheme: 'mailto',
      path: email,
    );
    try {
      final canLaunch = await canLaunchUrl(uri);
      if (canLaunch) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Cannot open email app')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Cannot open email app')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final compactHeight = 180.0;
    final expandedHeight = 280.0;
    final currentHeight = _isExpanded ? expandedHeight : compactHeight;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: currentHeight,
            decoration: _isExpanded
                ? null
                : BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(24),
                  ),
            child: _isExpanded
                ? BusinessCard(
                    name: widget.card.name,
                    organization: widget.card.organization,
                    jobTitle: widget.card.jobTitle,
                    email: widget.card.email,
                    phone: widget.card.phone,
                    location: widget.card.location,
                    about: widget.card.about,
                    website: widget.card.website,
                    background: widget.card.background ??
                        CardBackground.defaultGradient,
                    compactCard: false,
                    width: double.infinity,
                    enableSwipeFlip: true,
                    onTap: _handleCardTap,
                  )
                : Stack(
                    children: [
                      Positioned(
                        right: 0,
                        top: 0,
                        bottom: 0,
                        width: _deleteButtonWidth,
                        child: GestureDetector(
                          onTap: _showDeleteConfirmation,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(24),
                                bottomRight: Radius.circular(24),
                              ),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.delete,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onHorizontalDragUpdate: _handleDragUpdate,
                        onHorizontalDragEnd: _handleDragEnd,
                        child: Transform.translate(
                          offset: Offset(_dragOffset, 0),
                          child: GestureDetector(
                            onTap: _handleCardTap,
                            child: BusinessCard(
                              name: widget.card.name,
                              organization: widget.card.organization,
                              jobTitle: widget.card.jobTitle,
                              background: widget.card.background ??
                                  CardBackground.defaultGradient,
                              compactCard: true,
                              width: double.infinity,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
          if (_isExpanded)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.md),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _CategoryActionButton(
                    icon: Icons.call,
                    label: widget.l10n.call,
                    onTap: _handleCall,
                    color: Colors.green,
                  ),
                  _CategoryActionButton(
                    icon: Icons.email,
                    label: widget.l10n.email,
                    onTap: _handleEmail,
                    color: Colors.orange,
                  ),
                  _CategoryActionButton(
                    icon: Icons.share,
                    label: widget.l10n.share,
                    onTap: _handleShare,
                    color: Colors.blue,
                  ),
                  _CategoryActionButton(
                    icon: Icons.edit,
                    label: widget.l10n.edit,
                    onTap: _handleEdit,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  _CategoryActionButton(
                    icon: Icons.delete,
                    label: widget.l10n.delete,
                    onTap: _showDeleteConfirmation,
                    color: Colors.red,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _CategoryActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  const _CategoryActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.sm,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
