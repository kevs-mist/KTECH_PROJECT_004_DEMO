import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

class RegisterScreen extends ConsumerStatefulWidget {
  final UserRole role;

  const RegisterScreen({
    super.key,
    required this.role,
  });

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _medicalRegistrationController = TextEditingController();
  final _accessCodeController = TextEditingController();

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
    _confirmPasswordController.dispose();
    _medicalRegistrationController.dispose();
    _accessCodeController.dispose();
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
      await authRepository.register(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        medicalRegistration: _medicalRegistrationController.text.trim(),
        accessCode: _accessCodeController.text.trim(),
        role: widget.role,
      );

      if (mounted) {
        // Navigate to login after successful registration
        context.pop();
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Registration failed. Please try again.';
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

  String get _roleTitle {
    return widget.role == UserRole.dataEntry ? 'Data Entry' : 'Doctor';
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
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
                  'Create $_roleTitle account',
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                const SizedBox(height: AppTheme.space8),
                Text(
                  'Enter your details to create a new account.',
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
                  label: 'Password',
                  hint: 'At least 12 characters',
                  controller: _passwordController,
                  isCreate: true,
                  textInputAction: TextInputAction.next,
                ),
                PasswordField(
                  label: 'Confirm password',
                  controller: _confirmPasswordController,
                  validator: (value) => Validators.validateConfirmPassword(
                        _passwordController.text,
                        value,
                      )?.message,
                  textInputAction: TextInputAction.next,
                ),
                AuthTextField(
                  label: 'Medical registration number',
                  hint: 'e.g., GMC/12345-6',
                  controller: _medicalRegistrationController,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9/-]')),
                  ],
                  validator: (value) =>
                      Validators.validateMedicalRegistration(value)?.message,
                  textInputAction: TextInputAction.next,
                ),
                AuthTextField(
                  label: 'Access code',
                  hint: 'Enter your access code',
                  controller: _accessCodeController,
                  validator: (value) =>
                      Validators.validateAccessCode(value)?.message,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _handleSubmit(),
                ),
                const SizedBox(height: AppTheme.space24),
                PrimaryButton(
                  label: 'Create account',
                  onPressed: _handleSubmit,
                  isLoading: _isLoading,
                ),
                const SizedBox(height: AppTheme.space24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                    ),
                    TextButton(
                      onPressed: _handleBack,
                      child: const Text('Sign in'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
