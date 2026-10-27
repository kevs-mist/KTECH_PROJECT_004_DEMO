import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme.dart';
import '../../../models/user_role.dart';
import '../auth_form_state.dart';
import '../auth_repository.dart';
import '../validators.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/primary_button.dart';
import '../widgets/inline_banner.dart';
import '../widgets/back_link.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  final UserRole role;

  const ForgotPasswordScreen({
    super.key,
    required this.role,
  });

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  @override
  void initState() {
    super.initState();
    // Load saved email from shared state
    final savedEmail = ref.read(authFormStateProvider).email;
    if (savedEmail.isNotEmpty) {
      _emailController.text = savedEmail;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    // Save email to shared state
    ref.read(authFormStateProvider.notifier).setEmail(_emailController.text.trim());

    try {
      final authRepository = FakeAuthRepository();
      await authRepository.forgotPassword(
        email: _emailController.text.trim(),
        role: widget.role,
      );

      if (mounted) {
        setState(() {
          _successMessage =
              'Password reset link sent to ${_emailController.text.trim()}';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to send reset link. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _handleBack() {
    context.pop();
  }

  void _handleBackToLogin() {
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.space48,
          vertical: AppTheme.space48,
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              BackLink(onTap: _handleBack),
              const SizedBox(height: AppTheme.space32),
              Text(
                'Reset password',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: AppTheme.space8),
              Text(
                'Enter your email to receive a password reset link.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
              ),
              const SizedBox(height: AppTheme.space32),
              if (_errorMessage != null) ...[
                InlineBanner(
                  message: _errorMessage!,
                  type: BannerType.error,
                  onDismiss: () {
                    setState(() {
                      _errorMessage = null;
                    });
                  },
                ),
                const SizedBox(height: AppTheme.space24),
              ],
              if (_successMessage != null) ...[
                InlineBanner(
                  message: _successMessage!,
                  type: BannerType.success,
                  onDismiss: () {
                    setState(() {
                      _successMessage = null;
                    });
                  },
                ),
                const SizedBox(height: AppTheme.space24),
              ],
              AuthTextField(
                label: 'Email',
                hint: 'you@example.com',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                validator: (value) => Validators.validateEmail(value)?.message,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _handleSubmit(),
              ),
              const SizedBox(height: AppTheme.space24),
              PrimaryButton(
                label: 'Send reset link',
                onPressed: _handleSubmit,
                isLoading: _isLoading,
              ),
              const SizedBox(height: AppTheme.space24),
              if (_successMessage != null)
                Center(
                  child: TextButton(
                    onPressed: _handleBackToLogin,
                    child: const Text('Back to sign in'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
