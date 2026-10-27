import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme.dart';
import '../../../models/user_role.dart';
import '../auth_form_state.dart';
import '../auth_repository.dart';
import '../validators.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/password_field.dart';
import '../widgets/primary_button.dart';
import '../widgets/inline_banner.dart';
import '../widgets/back_link.dart';
import '../demo_role_dialog.dart';

class LoginScreen extends ConsumerStatefulWidget {
  final UserRole role;

  const LoginScreen({
    super.key,
    required this.role,
  });

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _focusNode = FocusNode();

  bool _isLoading = false;
  String? _errorMessage;

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
    _passwordController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Save email to shared state
    ref.read(authFormStateProvider.notifier).setEmail(_emailController.text.trim());

    try {
      final authRepository = FakeAuthRepository();
      await authRepository.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        role: widget.role,
      );

      if (mounted) {
        // Navigate to dashboard or home (for now, just go back to roles)
        context.go('/roles');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Sign in failed. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _handleForgotPassword() {
    context.push('/forgot/$rolePath');
  }

  void _handleRegister() {
    context.push('/register/$rolePath');
  }

  void _handleBack() {
    context.go('/roles');
  }

  String get rolePath {
    return widget.role == UserRole.dataEntry ? 'data-entry' : 'doctor';
  }

  String get roleTitle {
    return widget.role == UserRole.dataEntry ? 'Data Entry' : 'Doctor';
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
                'Sign in as $roleTitle',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: AppTheme.space8),
              Text(
                'Enter your credentials to access the admissions register.',
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
              AuthTextField(
                label: 'Email',
                hint: 'you@example.com',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                validator: (value) => Validators.validateEmail(value)?.message,
                textInputAction: TextInputAction.next,
              ),
              PasswordField(
                controller: _passwordController,
                onFieldSubmitted: (_) => _handleSubmit(),
              ),
              const SizedBox(height: AppTheme.space8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _handleForgotPassword,
                  child: const Text('Forgot password?'),
                ),
              ),
              const SizedBox(height: AppTheme.space24),
              PrimaryButton(
                label: 'Sign in',
                onPressed: _handleSubmit,
                isLoading: _isLoading,
              ),
              const SizedBox(height: AppTheme.space12),
              Center(
                child: TextButton(
                  onPressed: () => DemoRoleDialog.show(context),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.textSecondary,
                  ),
                  child: const Text('Just exploring? Try the demo →'),
                ),
              ),
              const SizedBox(height: AppTheme.space24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account? ",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                  ),
                  TextButton(
                    onPressed: _handleRegister,
                    child: const Text('Create account'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
