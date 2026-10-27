import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../../app/app_fonts.dart' as local_fonts;

import 'package:go_router/go_router.dart';

import '../../../app/theme.dart';
import '../demo_role_dialog.dart';

class RoleSelectionCards extends StatefulWidget {
  const RoleSelectionCards({super.key});

  @override
  State<RoleSelectionCards> createState() => _RoleSelectionCardsState();
}

class _RoleSelectionCardsState extends State<RoleSelectionCards>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _titleAnimation;
  late Animation<double> _card1Animation;
  late Animation<double> _card2Animation;
  late Animation<double> _footerAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _titleAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.4, curve: Curves.easeOutCubic),
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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Title
              FadeTransition(
                opacity: reduceMotion
                    ? const AlwaysStoppedAnimation(1.0)
                    : _titleAnimation,
                child: SlideTransition(
                  position:
                      Tween<Offset>(
                        begin: const Offset(0, 0.1),
                        end: Offset.zero,
                      ).animate(
                        reduceMotion
                            ? const AlwaysStoppedAnimation(1.0)
                            : _titleAnimation,
                      ),
                  child: Text(
                    'Sign in as',
                    style: local_fonts
                        .newsreader(
                          fontSize: 36,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.inkTeal,
                          height: 1.2,
                        )
                        .copyWith(fontFamilyFallback: ['Georgia', 'serif']),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Explanation
              FadeTransition(
                opacity: reduceMotion
                    ? const AlwaysStoppedAnimation(1.0)
                    : _titleAnimation,
                child: SlideTransition(
                  position:
                      Tween<Offset>(
                        begin: const Offset(0, 0.1),
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
                          fontSize: 15,
                          color: AppTheme.textSecondary,
                          height: 1.5,
                        )
                        .copyWith(fontFamilyFallback: ['Arial', 'sans-serif']),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              // Data Entry Card
              _RoleCard(
                icon: _AdminIcon(),
                title: 'Data Entry',
                description: 'Admits patients and completes discharges.',
                onTap: () => context.go('/login/data-entry'),
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
                description:
                    'Views current and past admissions in read-only mode.',
                onTap: () => context.go('/login/doctor'),
                animation: reduceMotion
                    ? const AlwaysStoppedAnimation(1.0)
                    : _card2Animation,
                isFilled: false,
              ),
              const SizedBox(height: 24),
              // Demo link
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
                  child: Center(
                    child: TextButton.icon(
                      onPressed: () => DemoRoleDialog.show(context),
                      icon: const Icon(Icons.science_outlined, size: 16),
                      label: Text(
                        'Explore with sample data →',
                        style: local_fonts
                            .instrumentSans(
                              fontSize: 14,
                              color: AppTheme.textSecondary,
                            )
                            .copyWith(
                              fontFamilyFallback: ['Arial', 'sans-serif'],
                            ),
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: AppTheme.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Divider
              FadeTransition(
                opacity: reduceMotion
                    ? const AlwaysStoppedAnimation(1.0)
                    : _footerAnimation,
                child: Container(height: 1, color: AppTheme.hairline),
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
                  child: Row(
                    children: [
                      Icon(
                        Icons.lock_outline,
                        size: 16,
                        color: AppTheme.textSecondary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Records are encrypted. Sign-in requires two-factor verification.',
                          style: local_fonts
                              .instrumentSans(
                                fontSize: 13,
                                color: AppTheme.textSecondary,
                              )
                              .copyWith(
                                fontFamilyFallback: ['Arial', 'sans-serif'],
                              ),
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

class _RoleCardState extends State<_RoleCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: widget.animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.1),
          end: Offset.zero,
        ).animate(widget.animation),
        child: AnimatedBuilder(
          animation: widget.animation,
          builder: (context, child) {
            final scale = _isPressed ? 0.97 : 1.0;
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
                onTapDown: (_) => setState(() => _isPressed = true),
                onTapUp: (_) => setState(() => _isPressed = false),
                onTapCancel: () => setState(() => _isPressed = false),
                onTap: widget.onTap,
                child: Container(
                  decoration: BoxDecoration(
                    color: widget.isFilled
                        ? AppTheme.inkTeal
                        : AppTheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _isPressed
                          ? AppTheme.error
                          : widget.isFilled
                          ? Colors.transparent
                          : AppTheme.inkTeal.withValues(alpha: 0.3),
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
                                ? AppTheme.paper.withValues(alpha: 0.2)
                                : AppTheme.inkTeal.withValues(alpha: 0.1),
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
                                          ? AppTheme.paper
                                          : AppTheme.textPrimary,
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
                                          ? AppTheme.paper.withValues(
                                              alpha: 0.8,
                                            )
                                          : AppTheme.textSecondary,
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
      ..color = AppTheme.paper
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
      ..color = AppTheme.textPrimary
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
