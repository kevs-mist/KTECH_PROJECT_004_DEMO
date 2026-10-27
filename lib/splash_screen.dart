import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'app/theme.dart';
import 'features/auth/auth_controller.dart';

class SplashScreen extends ConsumerStatefulWidget {
  final Duration duration;

  const SplashScreen({super.key, this.duration = const Duration(seconds: 2)});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    // Start fade-in animation after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _controller.forward();
      }
    });

    // Navigate to initial route after duration
    Future.delayed(widget.duration, () {
      if (mounted) {
        final authState = ref.read(authControllerProvider);
        if (authState.isAuthenticated) {
          context.go('/dashboard');
        } else {
          context.go('/roles');
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.inkTeal,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: SizedBox(
                  width: 140,
                  height: 140,
                  child: Image.asset(
                    'assets/images/image.png',
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                    errorBuilder: (context, error, stackTrace) {
                      // Placeholder if image fails to load
                      return Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          color: AppTheme.paper,
                          borderRadius: BorderRadius.circular(28),
                        ),
                        child: Icon(
                          Icons.local_hospital,
                          size: 60,
                          color: AppTheme.inkTeal,
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // "Made with KTech" text
              Text(
                'Made with KTech',
                style: Theme.of(context).textTheme.bodySmall
                    ?.copyWith(color: AppTheme.paper.withValues(alpha: 0.8)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
