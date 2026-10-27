import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../app/app_fonts.dart' as local_fonts;

import '../../../app/theme.dart';
import '../../models/user_role.dart';
import '../../../app/router.dart' show ScreenType;

class AppShell extends StatelessWidget {
  final Widget child;
  final ScreenType screenType;
  final UserRole? role;

  const AppShell({
    super.key,
    required this.child,
    required this.screenType,
    this.role,
  });

  @override
  Widget build(BuildContext context) {
    final reduceMotion = SchedulerBinding
        .instance
        .platformDispatcher
        .accessibilityFeatures
        .disableAnimations;

    return Scaffold(
      backgroundColor: AppTheme.inkTeal,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxHeight < AppTheme.minWindowHeight;

          return isCompact
              ? _buildCompactLayout(reduceMotion)
              : _buildSplitLayout(reduceMotion);
        },
      ),
    );
  }

  Widget _buildSplitLayout(bool reduceMotion) {
    return Row(
      children: [
        // Left Panel (5 parts) - teal
        Expanded(
          flex: 5,
          child: _LeftPanel(
            screenType: screenType,
            role: role,
            reduceMotion: reduceMotion,
          ),
        ),
        // Right Panel (6 parts) - white
        Expanded(
          flex: 6,
          child: Container(
            color: AppTheme.surface,
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
                          child: AnimatedSwitcher(
                            duration: reduceMotion
                                ? const Duration(milliseconds: 150)
                                : const Duration(milliseconds: 350),
                            switchInCurve: Curves.easeOutCubic,
                            switchOutCurve: Curves.easeInCubic,
                            transitionBuilder: (child, animation) {
                              return SlideTransition(
                                position:
                                    Tween<Offset>(
                                      begin: const Offset(0.03, 0),
                                      end: Offset.zero,
                                    ).animate(
                                      CurvedAnimation(
                                        parent: animation,
                                        curve: Curves.easeOutCubic,
                                      ),
                                    ),
                                child: FadeTransition(
                                  opacity: animation,
                                  child: child,
                                ),
                              );
                            },
                            child: child,
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

  Widget _buildCompactLayout(bool reduceMotion) {
    return Column(
      children: [
        // Left Panel as compact header
        SizedBox(
          height: AppTheme.compactHeaderHeight,
          child: _LeftPanel(
            screenType: screenType,
            role: role,
            reduceMotion: reduceMotion,
            isCompact: true,
          ),
        ),
        // Right Panel below
        Expanded(
          child: Container(
            color: AppTheme.surface,
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
                          child: AnimatedSwitcher(
                            duration: reduceMotion
                                ? const Duration(milliseconds: 150)
                                : const Duration(milliseconds: 350),
                            switchInCurve: Curves.easeOutCubic,
                            switchOutCurve: Curves.easeInCubic,
                            transitionBuilder: (child, animation) {
                              return SlideTransition(
                                position:
                                    Tween<Offset>(
                                      begin: const Offset(0, 0.03),
                                      end: Offset.zero,
                                    ).animate(
                                      CurvedAnimation(
                                        parent: animation,
                                        curve: Curves.easeOutCubic,
                                      ),
                                    ),
                                child: FadeTransition(
                                  opacity: animation,
                                  child: child,
                                ),
                              );
                            },
                            child: child,
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

class _LeftPanel extends StatelessWidget {
  final ScreenType screenType;
  final UserRole? role;
  final bool reduceMotion;
  final bool isCompact;

  const _LeftPanel({
    required this.screenType,
    this.role,
    required this.reduceMotion,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final padding = isCompact ? AppTheme.space24 : AppTheme.space48;
    final titleScale = isCompact ? 0.7 : 1.0;
    final textScale = isCompact ? 0.8 : 1.0;

    return Container(
      color: AppTheme.inkTeal,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Padding(
                padding: EdgeInsets.all(padding),
                child: AnimatedSwitcher(
                  duration: reduceMotion
                      ? const Duration(milliseconds: 150)
                      : const Duration(milliseconds: 250),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  transitionBuilder: (child, animation) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                  child: Column(
                    key: ValueKey('${screenType}_$role'),
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: _buildContent(titleScale, textScale),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildContent(double titleScale, double textScale) {
    final children = <Widget>[
      Text(
        'Arpan Newborn Care Centre',
        style: local_fonts
            .instrumentSans(
              fontSize: 18 * textScale,
              color: AppTheme.paper,
              letterSpacing: 0.5,
            )
            .copyWith(fontFamilyFallback: ['Arial', 'sans-serif']),
      ),
      SizedBox(height: AppTheme.space32 * textScale),
    ];

    switch (screenType) {
      case ScreenType.roleSelection:
        children.addAll([
          Text(
            'Admissions Register',
            style: local_fonts
                .newsreader(
                  fontSize: 48 * titleScale,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.paper,
                  height: 1.1,
                )
                .copyWith(fontFamilyFallback: ['Georgia', 'serif']),
          ),
          SizedBox(height: AppTheme.space24 * textScale),
          Text(
            'Secure patient record management for maternity and delivery care. Choose your role to continue.',
            style: local_fonts
                .instrumentSans(
                  fontSize: 16 * textScale,
                  color: AppTheme.paper.withValues(alpha: 0.8),
                  height: 1.6,
                )
                .copyWith(fontFamilyFallback: ['Arial', 'sans-serif']),
          ),
        ]);
        break;

      case ScreenType.login:
        children.addAll([
          Text(
            _getLoginTitle(),
            style: local_fonts
                .newsreader(
                  fontSize: 48 * titleScale,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.paper,
                  height: 1.1,
                )
                .copyWith(fontFamilyFallback: ['Georgia', 'serif']),
          ),
          SizedBox(height: AppTheme.space24 * textScale),
          Text(
            _getLoginDescription(),
            style: local_fonts
                .instrumentSans(
                  fontSize: 16 * textScale,
                  color: AppTheme.paper.withValues(alpha: 0.8),
                  height: 1.6,
                )
                .copyWith(fontFamilyFallback: ['Arial', 'sans-serif']),
          ),
        ]);
        break;

      case ScreenType.forgotPassword:
        children.addAll([
          Text(
            'Reset your password',
            style: local_fonts
                .newsreader(
                  fontSize: 48 * titleScale,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.paper,
                  height: 1.1,
                )
                .copyWith(fontFamilyFallback: ['Georgia', 'serif']),
          ),
          SizedBox(height: AppTheme.space24 * textScale),
          Text(
            'We\'ll send a reset link to the email on your account.',
            style: local_fonts
                .instrumentSans(
                  fontSize: 16 * textScale,
                  color: AppTheme.paper.withValues(alpha: 0.8),
                  height: 1.6,
                )
                .copyWith(fontFamilyFallback: ['Arial', 'sans-serif']),
          ),
        ]);
        break;

      case ScreenType.register:
        children.addAll([
          Text(
            _getRegisterTitle(),
            style: local_fonts
                .newsreader(
                  fontSize: 48 * titleScale,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.paper,
                  height: 1.1,
                )
                .copyWith(fontFamilyFallback: ['Georgia', 'serif']),
          ),
          SizedBox(height: AppTheme.space24 * textScale),
          Text(
            'A hospital access code is required to create an account.',
            style: local_fonts
                .instrumentSans(
                  fontSize: 16 * textScale,
                  color: AppTheme.paper.withValues(alpha: 0.8),
                  height: 1.6,
                )
                .copyWith(fontFamilyFallback: ['Arial', 'sans-serif']),
          ),
        ]);
        break;
    }

    return children;
  }

  String _getLoginTitle() {
    if (role == UserRole.doctor) return 'Doctor sign in';
    return 'Data entry sign in';
  }

  String _getLoginDescription() {
    if (role == UserRole.doctor) {
      return 'View current and past admissions in read-only mode.';
    }
    return 'Admit patients, record discharges, and review the register.';
  }

  String _getRegisterTitle() {
    if (role == UserRole.doctor) return 'Add a new doctor';
    return 'Add a new data entry professional';
  }
}
