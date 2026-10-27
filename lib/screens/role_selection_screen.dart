import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../app/app_fonts.dart' as local_fonts;

import 'package:go_router/go_router.dart';

import '../features/auth/demo_role_dialog.dart';

class _AppColors {
  static const Color inkTeal = Color(0xFF0F4C5C);
  static const Color clinicalWhite = Color(0xFFFAF9F5);
  static const Color mutedCoral = Color(0xFFE8998D);
  static const Color ink = Color(0xFF1A1A1A);
  static const Color quiet = Color(0xFF6B6B6B);
  static const Color white = Color(0xFFFFFFFF);
  static const Color offWhite = Color(0xFFF5F4F0);
}

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _headerAnimation;
  late Animation<double> _titleAnimation;
  late Animation<double> _card1Animation;
  late Animation<double> _card2Animation;
  late Animation<double> _footerAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _headerAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.3, curve: Curves.easeOutCubic),
    );

    _pulseAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
    );

    _titleAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.1, 0.5, curve: Curves.easeOutCubic),
    );

    _card1Animation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.2, 0.6, curve: Curves.easeOutCubic),
    );

    _card2Animation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.3, 0.7, curve: Curves.easeOutCubic),
    );

    _footerAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.5, 1.0, curve: Curves.easeOutCubic),
    );

    final reduceMotion = SchedulerBinding
        .instance
        .platformDispatcher
        .accessibilityFeatures
        .disableAnimations;
    if (reduceMotion) {
      _controller.value = 1.0;
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = SchedulerBinding
        .instance
        .platformDispatcher
        .accessibilityFeatures
        .disableAnimations;

    return Scaffold(
      backgroundColor: _AppColors.inkTeal,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isPhone = constraints.maxWidth < 600;
          final isCompact = constraints.maxWidth < 900;

          return ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: isPhone
                ? _buildPhoneLayout(reduceMotion)
                : _buildSplitLayout(reduceMotion, isCompact),
          );
        },
      ),
    );
  }

  Widget _buildSplitLayout(bool reduceMotion, bool isCompact) {
    final padding = isCompact ? 32.0 : 64.0;
    final titleScale = isCompact ? 0.85 : 1.0;
    final textScale = isCompact ? 0.85 : 1.0;

    return Row(
      children: [
        // Left Panel (5 parts)
        Expanded(
          flex: 5,
          child: Container(
            color: _AppColors.inkTeal,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(padding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FadeTransition(
                            opacity: reduceMotion
                                ? const AlwaysStoppedAnimation(1.0)
                                : _headerAnimation,
                            child: SlideTransition(
                              position:
                                  Tween<Offset>(
                                    begin: const Offset(-0.1, 0),
                                    end: Offset.zero,
                                  ).animate(
                                    reduceMotion
                                        ? const AlwaysStoppedAnimation(1.0)
                                        : _headerAnimation,
                                  ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Arpan Newborn Care Centre',
                                    style: local_fonts
                                        .instrumentSans(
                                          fontSize: 18 * textScale,
                                          color: _AppColors.offWhite,
                                          letterSpacing: 0.5,
                                        )
                                        .copyWith(
                                          fontFamilyFallback: [
                                            'Arial',
                                            'sans-serif',
                                          ],
                                        ),
                                  ),
                                  SizedBox(height: 32 * textScale),
                                  if (!reduceMotion)
                                    FadeTransition(
                                      opacity: _pulseAnimation,
                                      child: const _ECGPulseLine(isLarge: true),
                                    ),
                                  SizedBox(height: 48 * textScale),
                                  Text(
                                    'Admissions Register',
                                    style: local_fonts
                                        .newsreader(
                                          fontSize: 48 * titleScale,
                                          fontWeight: FontWeight.w500,
                                          color: _AppColors.offWhite,
                                          height: 1.1,
                                        )
                                        .copyWith(
                                          fontFamilyFallback: [
                                            'Georgia',
                                            'serif',
                                          ],
                                        ),
                                  ),
                                  SizedBox(height: 24 * textScale),
                                  Text(
                                    'Secure patient record management for maternity and delivery care. Data entry staff admit patients and complete discharges. Doctors view current and past admissions in read-only mode.',
                                    style: local_fonts
                                        .instrumentSans(
                                          fontSize: 16 * textScale,
                                          color: _AppColors.offWhite.withValues(
                                            alpha: 0.8,
                                          ),
                                          height: 1.6,
                                        )
                                        .copyWith(
                                          fontFamilyFallback: [
                                            'Arial',
                                            'sans-serif',
                                          ],
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        // Right Panel (6 parts)
        Expanded(
          flex: 6,
          child: Container(
            color: _AppColors.clinicalWhite,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: padding),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 420),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Title
                              FadeTransition(
                                opacity: reduceMotion
                                    ? const AlwaysStoppedAnimation(1.0)
                                    : _titleAnimation,
                                child: SlideTransition(
                                  position:
                                      Tween<Offset>(
                                        begin: const Offset(0.1, 0),
                                        end: Offset.zero,
                                      ).animate(
                                        reduceMotion
                                            ? const AlwaysStoppedAnimation(1.0)
                                            : _titleAnimation,
                                      ),
                                  child: Semantics(
                                    header: true,
                                    label: 'Sign in as',
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        'Sign in as',
                                        style: local_fonts
                                            .newsreader(
                                              fontSize: 36 * titleScale,
                                              fontWeight: FontWeight.w500,
                                              color: _AppColors.inkTeal,
                                              height: 1.2,
                                            )
                                            .copyWith(
                                              fontFamilyFallback: [
                                                'Georgia',
                                                'serif',
                                              ],
                                            ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 16 * textScale),
                              // Explanation
                              FadeTransition(
                                opacity: reduceMotion
                                    ? const AlwaysStoppedAnimation(1.0)
                                    : _titleAnimation,
                                child: SlideTransition(
                                  position:
                                      Tween<Offset>(
                                        begin: const Offset(0.1, 0),
                                        end: Offset.zero,
                                      ).animate(
                                        reduceMotion
                                            ? const AlwaysStoppedAnimation(1.0)
                                            : _titleAnimation,
                                      ),
                                  child: Text(
                                    'Data entry staff admit patients and complete discharges. Doctors view records in read-only mode.',
                                    style: local_fonts
                                        .instrumentSans(
                                          fontSize: 15 * textScale,
                                          color: _AppColors.quiet,
                                          height: 1.5,
                                        )
                                        .copyWith(
                                          fontFamilyFallback: [
                                            'Arial',
                                            'sans-serif',
                                          ],
                                        ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 40 * textScale),
                              // Data Entry Card
                              _RoleCard(
                                icon: _AdminIcon(),
                                title: 'Data Entry',
                                description:
                                    'Admits patients and completes discharges.',
                                onTap: () {
                                  context.push('/login/data-entry');
                                },
                                animation: reduceMotion
                                    ? const AlwaysStoppedAnimation(1.0)
                                    : _card1Animation,
                                isFilled: true,
                              ),
                              const SizedBox(height: 32),
                              // Doctor Card
                              _RoleCard(
                                icon: _DoctorIcon(),
                                title: 'Doctor',
                                description: 'Views current and past admissions in read-only mode.',
                                onTap: () {
                                  context.push('/login/doctor');
                                },
                                animation: reduceMotion
                                    ? const AlwaysStoppedAnimation(1.0)
                                    : _card2Animation,
                                isFilled: false,
                              ),
                              const SizedBox(height: 24),
                              TextButton.icon(
                                onPressed: () => DemoRoleDialog.show(context),
                                icon: const Icon(Icons.science_outlined, size: 16),
                                label: Text(
                                  'Explore with sample data →',
                                  style: local_fonts
                                      .instrumentSans(
                                        fontSize: 14,
                                        color: _AppColors.quiet,
                                      )
                                      .copyWith(
                                        fontFamilyFallback: [
                                          'Arial',
                                          'sans-serif',
                                        ],
                                      ),
                                ),
                              ),
                              SizedBox(height: 24 * textScale),
                              // Footer
                              FadeTransition(
                                opacity: reduceMotion
                                    ? const AlwaysStoppedAnimation(1.0)
                                    : _footerAnimation,
                                child: SlideTransition(
                                  position:
                                      Tween<Offset>(
                                        begin: const Offset(0, 0.1),
                                        end: Offset.zero,
                                      ).animate(
                                        reduceMotion
                                            ? const AlwaysStoppedAnimation(1.0)
                                            : _footerAnimation,
                                      ),
                                  child: Column(
                                    children: [
                                      const Divider(height: 1, thickness: 1),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 20,
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.lock_outline,
                                              size: 16,
                                              color: _AppColors.quiet,
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                'Records are encrypted. Sign-in requires two-factor verification.',
                                                style: local_fonts
                                                    .instrumentSans(
                                                      fontSize: 13,
                                                      color: _AppColors.quiet,
                                                    )
                                                    .copyWith(
                                                      fontFamilyFallback: [
                                                        'Arial',
                                                        'sans-serif',
                                                      ],
                                                    ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneLayout(bool reduceMotion) {
    return Column(
      children: [
        // Left Panel as compact header (40% height)
        Expanded(
          flex: 4,
          child: Container(
            color: _AppColors.inkTeal,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FadeTransition(
                            opacity: reduceMotion
                                ? const AlwaysStoppedAnimation(1.0)
                                : _headerAnimation,
                            child: SlideTransition(
                              position:
                                  Tween<Offset>(
                                    begin: const Offset(0, -0.1),
                                    end: Offset.zero,
                                  ).animate(
                                    reduceMotion
                                        ? const AlwaysStoppedAnimation(1.0)
                                        : _headerAnimation,
                                  ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Arpan Newborn Care Centre',
                                    style: local_fonts
                                        .instrumentSans(
                                          fontSize: 14,
                                          color: _AppColors.offWhite,
                                          letterSpacing: 0.5,
                                        )
                                        .copyWith(
                                          fontFamilyFallback: [
                                            'Arial',
                                            'sans-serif',
                                          ],
                                        ),
                                  ),
                                  const SizedBox(height: 16),
                                  if (!reduceMotion)
                                    FadeTransition(
                                      opacity: _pulseAnimation,
                                      child: const _ECGPulseLine(isLarge: true),
                                    ),
                                  const SizedBox(height: 24),
                                  Text(
                                    'Admissions Register',
                                    style: local_fonts
                                        .newsreader(
                                          fontSize: 32,
                                          fontWeight: FontWeight.w500,
                                          color: _AppColors.offWhite,
                                          height: 1.1,
                                        )
                                        .copyWith(
                                          fontFamilyFallback: [
                                            'Georgia',
                                            'serif',
                                          ],
                                        ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Secure patient record management for maternity and delivery care.',
                                    style: local_fonts
                                        .instrumentSans(
                                          fontSize: 13,
                                          color: _AppColors.offWhite.withValues(
                                            alpha: 0.8,
                                          ),
                                          height: 1.5,
                                        )
                                        .copyWith(
                                          fontFamilyFallback: [
                                            'Arial',
                                            'sans-serif',
                                          ],
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        // Right Panel below (60% height)
        Expanded(
          flex: 6,
          child: Container(
            color: _AppColors.clinicalWhite,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 420),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Title
                              FadeTransition(
                                opacity: reduceMotion
                                    ? const AlwaysStoppedAnimation(1.0)
                                    : _titleAnimation,
                                child: SlideTransition(
                                  position:
                                      Tween<Offset>(
                                        begin: const Offset(0, -0.1),
                                        end: Offset.zero,
                                      ).animate(
                                        reduceMotion
                                            ? const AlwaysStoppedAnimation(1.0)
                                            : _titleAnimation,
                                      ),
                                  child: Semantics(
                                    header: true,
                                    label: 'Sign in as',
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        'Sign in as',
                                        style: local_fonts
                                            .newsreader(
                                              fontSize: 28,
                                              fontWeight: FontWeight.w500,
                                              color: _AppColors.inkTeal,
                                              height: 1.2,
                                            )
                                            .copyWith(
                                              fontFamilyFallback: [
                                                'Georgia',
                                                'serif',
                                              ],
                                            ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              // Explanation
                              FadeTransition(
                                opacity: reduceMotion
                                    ? const AlwaysStoppedAnimation(1.0)
                                    : _titleAnimation,
                                child: SlideTransition(
                                  position:
                                      Tween<Offset>(
                                        begin: const Offset(0, -0.1),
                                        end: Offset.zero,
                                      ).animate(
                                        reduceMotion
                                            ? const AlwaysStoppedAnimation(1.0)
                                            : _titleAnimation,
                                      ),
                                  child: Text(
                                    'Data entry staff admit patients and complete discharges. Doctors view records in read-only mode.',
                                    style: local_fonts
                                        .instrumentSans(
                                          fontSize: 14,
                                          color: _AppColors.quiet,
                                          height: 1.5,
                                        )
                                        .copyWith(
                                          fontFamilyFallback: [
                                            'Arial',
                                            'sans-serif',
                                          ],
                                        ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 32),
                              // Data Entry Card
                              _RoleCard(
                                icon: _AdminIcon(),
                                title: 'Data Entry',
                                description:
                                    'Admits patients and completes discharges.',
                                onTap: () {
                                  context.push('/login/data-entry');
                                },
                                animation: reduceMotion
                                    ? const AlwaysStoppedAnimation(1.0)
                                    : _card1Animation,
                                isFilled: true,
                              ),
                              const SizedBox(height: 24),
                              // Doctor Card
                              _RoleCard(
                                icon: _DoctorIcon(),
                                title: 'Doctor',
                                description: 'Views current and past admissions in read-only mode.',
                                onTap: () {
                                  context.push('/login/doctor');
                                },
                                animation: reduceMotion
                                    ? const AlwaysStoppedAnimation(1.0)
                                    : _card2Animation,
                                isFilled: false,
                              ),
                              const SizedBox(height: 24),
                              TextButton.icon(
                                onPressed: () => DemoRoleDialog.show(context),
                                icon: const Icon(Icons.science_outlined, size: 16),
                                label: Text(
                                  'Explore with sample data →',
                                  style: local_fonts
                                      .instrumentSans(
                                        fontSize: 14,
                                        color: _AppColors.quiet,
                                      )
                                      .copyWith(
                                        fontFamilyFallback: [
                                          'Arial',
                                          'sans-serif',
                                        ],
                                      ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              // Footer
                              FadeTransition(
                                opacity: reduceMotion
                                    ? const AlwaysStoppedAnimation(1.0)
                                    : _footerAnimation,
                                child: SlideTransition(
                                  position:
                                      Tween<Offset>(
                                        begin: const Offset(0, 0.1),
                                        end: Offset.zero,
                                      ).animate(
                                        reduceMotion
                                            ? const AlwaysStoppedAnimation(1.0)
                                            : _footerAnimation,
                                      ),
                                  child: Column(
                                    children: [
                                      const Divider(height: 1, thickness: 1),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 16,
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.lock_outline,
                                              size: 14,
                                              color: _AppColors.quiet,
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                'Records are encrypted. Sign-in requires two-factor verification.',
                                                style: local_fonts
                                                    .instrumentSans(
                                                      fontSize: 12,
                                                      color: _AppColors.quiet,
                                                    )
                                                    .copyWith(
                                                      fontFamilyFallback: [
                                                        'Arial',
                                                        'sans-serif',
                                                      ],
                                                    ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _RoleCard extends StatefulWidget {
  final Widget icon;
  final String title;
  final String description;
  final VoidCallback onTap;
  final Animation<double> animation;
  final bool isFilled;

  const _RoleCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
    required this.animation,
    required this.isFilled,
  });

  @override
  State<_RoleCard> createState() => _RoleCardState();
}

class _RoleCardState extends State<_RoleCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressController;
  late Animation<double> _pressAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _pressAnimation = CurvedAnimation(
      parent: _pressController,
      curve: Curves.easeOutBack,
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  void _handlePress() {
    setState(() {
      _isPressed = true;
    });
    _pressController.forward();
  }

  void _handleRelease() {
    if (_isPressed) {
      setState(() {
        _isPressed = false;
      });
      _pressController.reverse().then((_) {
        if (mounted) {
          widget.onTap();
        }
      });
    }
  }

  void _handleCancel() {
    if (_isPressed) {
      setState(() {
        _isPressed = false;
      });
      _pressController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = SchedulerBinding
        .instance
        .platformDispatcher
        .accessibilityFeatures
        .disableAnimations;

    return FadeTransition(
      opacity: widget.animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.1),
          end: Offset.zero,
        ).animate(widget.animation),
        child: AnimatedBuilder(
          animation: _pressAnimation,
          builder: (context, child) {
            final scale = reduceMotion
                ? 1.0
                : _isPressed
                ? 0.97
                : 1.0;
            return Transform.scale(scale: scale, child: child);
          },
          child: Semantics(
            button: true,
            label: '${widget.title}. ${widget.description}',
            hint: 'Double tap to sign in as ${widget.title}',
            child: Focus(
              onFocusChange: (hasFocus) {
                setState(() {
                  _isPressed = hasFocus;
                });
              },
              child: GestureDetector(
                onTapDown: (_) => _handlePress(),
                onTapUp: (_) => _handleRelease(),
                onTapCancel: _handleCancel,
                onTap: widget.onTap,
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 420),
                  decoration: BoxDecoration(
                    color: widget.isFilled
                        ? _AppColors.inkTeal
                        : _AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _isPressed
                          ? _AppColors.mutedCoral
                          : widget.isFilled
                          ? Colors.transparent
                          : _AppColors.inkTeal.withValues(alpha: 0.3),
                      width: widget.isFilled ? 0 : 1,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      children: [
                        // Icon in small circle
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: widget.isFilled
                                ? _AppColors.offWhite.withValues(alpha: 0.2)
                                : _AppColors.inkTeal.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: widget.icon,
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.title,
                                style: local_fonts
                                    .instrumentSans(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                      color: widget.isFilled
                                          ? _AppColors.white
                                          : _AppColors.ink,
                                    )
                                    .copyWith(
                                      fontFamilyFallback: [
                                        'Arial',
                                        'sans-serif',
                                      ],
                                    ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                widget.description,
                                style: local_fonts
                                    .instrumentSans(
                                      fontSize: 15,
                                      color: widget.isFilled
                                          ? _AppColors.white.withValues(
                                              alpha: 0.8,
                                            )
                                          : _AppColors.quiet,
                                      height: 1.4,
                                    )
                                    .copyWith(
                                      fontFamilyFallback: [
                                        'Arial',
                                        'sans-serif',
                                      ],
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ECGPulseLine extends StatelessWidget {
  final bool isLarge;

  const _ECGPulseLine({this.isLarge = false});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(double.infinity, isLarge ? 32 : 24),
      painter: _ECGPulsePainter(isLarge: isLarge),
    );
  }
}

class _ECGPulsePainter extends CustomPainter {
  final bool isLarge;

  _ECGPulsePainter({this.isLarge = false});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isLarge ? _AppColors.offWhite : _AppColors.inkTeal
      ..strokeWidth = isLarge ? 2.0 : 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final width = size.width;
    final height = size.height;
    final centerY = height / 2;
    final pulseHeight = isLarge ? 12.0 : 8.0;

    // Start with flat line
    path.moveTo(0, centerY);
    path.lineTo(width * 0.3, centerY);

    // ECG pulse
    path.lineTo(width * 0.35, centerY);
    path.lineTo(width * 0.38, centerY - pulseHeight);
    path.lineTo(width * 0.42, centerY + pulseHeight);
    path.lineTo(width * 0.45, centerY);
    path.lineTo(width * 0.55, centerY);

    // Continue flat
    path.lineTo(width, centerY);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _AdminIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: const Size(24, 24), painter: _AdminIconPainter());
  }
}

class _AdminIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = _AppColors.offWhite
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    final center = size.width / 2;

    // Shield outline
    path.moveTo(center - 4, 5);
    path.lineTo(center + 4, 5);
    path.lineTo(center + 6, 7);
    path.lineTo(center + 6, 14);
    path.lineTo(center, 20);
    path.lineTo(center - 6, 14);
    path.lineTo(center - 6, 7);
    path.close();

    // Checkmark
    path.moveTo(center - 1.5, 13);
    path.lineTo(center + 0.5, 15);
    path.lineTo(center + 3.5, 11);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _DoctorIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: const Size(24, 24), painter: _DoctorIconPainter());
  }
}

class _DoctorIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = _AppColors.ink
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    final center = size.width / 2;

    // Stethoscope outline
    path.moveTo(center - 5, 6);
    path.quadraticBezierTo(center - 5, 10, center, 10);
    path.quadraticBezierTo(center + 5, 10, center + 5, 6);

    // Tube
    path.moveTo(center, 10);
    path.lineTo(center, 16);

    // Left ear piece
    path.moveTo(center, 16);
    path.quadraticBezierTo(center - 4, 16, center - 4, 19);
    path.arcToPoint(
      Offset(center - 2, 21),
      radius: const Radius.circular(2),
      clockwise: false,
    );
    path.quadraticBezierTo(center, 21, center, 19);

    // Right ear piece
    path.moveTo(center, 16);
    path.quadraticBezierTo(center + 4, 16, center + 4, 19);
    path.arcToPoint(
      Offset(center + 2, 21),
      radius: const Radius.circular(2),
      clockwise: true,
    );
    path.quadraticBezierTo(center, 21, center, 19);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
