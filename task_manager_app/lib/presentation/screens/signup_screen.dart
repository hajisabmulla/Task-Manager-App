import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/validators.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_event.dart';
import '../blocs/auth/auth_state.dart';
import '../widgets/app_button.dart';
import '../widgets/app_text_field.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameKey = GlobalKey();
  final _emailKey = GlobalKey();
  final _passwordKey = GlobalKey();
  final _confirmPasswordKey = GlobalKey();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _nameFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  void _scrollToFirstError() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (AppValidators.name(_nameController.text) != null) {
        _nameFocusNode.requestFocus();
        if (_nameKey.currentContext != null) {
          Scrollable.ensureVisible(
            _nameKey.currentContext!,
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeInOut,
            alignment: 0.1,
          );
        }
      } else if (AppValidators.email(_emailController.text) != null) {
        _emailFocusNode.requestFocus();
        if (_emailKey.currentContext != null) {
          Scrollable.ensureVisible(
            _emailKey.currentContext!,
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeInOut,
            alignment: 0.1,
          );
        }
      } else if (AppValidators.password(_passwordController.text) != null) {
        _passwordFocusNode.requestFocus();
        if (_passwordKey.currentContext != null) {
          Scrollable.ensureVisible(
            _passwordKey.currentContext!,
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeInOut,
            alignment: 0.1,
          );
        }
      } else if (AppValidators.confirmPassword(
            _confirmPasswordController.text,
            _passwordController.text,
          ) !=
          null) {
        _confirmPasswordFocusNode.requestFocus();
        if (_confirmPasswordKey.currentContext != null) {
          Scrollable.ensureVisible(
            _confirmPasswordKey.currentContext!,
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeInOut,
            alignment: 0.1,
          );
        }
      }
    });
  }

  void _onSignup() {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      _scrollToFirstError();
      return;
    }

    context.read<AuthBloc>().add(
      AuthSignupRequested(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            context.go('/tasks');
          } else if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.xl,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // App Logo & Header
                        Center(
                          child: Container(
                            width: 68,
                            height: 68,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                AppSpacing.radiusLg,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.25,
                                  ),
                                  blurRadius: 16,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(
                                AppSpacing.radiusLg,
                              ),
                              child: Image.asset(
                                'assets/icons/app_icon.png',
                                width: 68,
                                height: 68,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                  color: AppColors.primaryLight,
                                  child: const Icon(
                                    Icons.person_add_alt_1_outlined,
                                    size: 36,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        const Text(
                          AppStrings.signupTitle,
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimaryLight,
                            letterSpacing: -0.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        const Text(
                          AppStrings.signupSubtitle,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondaryLight,
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.xl),

                        // Full Name Field
                        Container(
                          key: _nameKey,
                          child: AppTextField(
                            label: 'Full Name',
                            hint: 'e.g. John Doe',
                            controller: _nameController,
                            focusNode: _nameFocusNode,
                            isRequired: true,
                            textCapitalization: TextCapitalization.words,
                            inputFormatters: [CapitalizeWordsFormatter()],
                            validator: AppValidators.name,
                            prefixIcon: const Icon(
                              Icons.person_outline,
                              size: 20,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),

                        // Email Field
                        Container(
                          key: _emailKey,
                          child: AppTextField(
                            label: 'Email Address',
                            hint: 'you@example.com',
                            controller: _emailController,
                            focusNode: _emailFocusNode,
                            isRequired: true,
                            keyboardType: TextInputType.emailAddress,
                            inputFormatters: [EmailInputFormatter()],
                            validator: AppValidators.email,
                            prefixIcon: const Icon(
                              Icons.mail_outline,
                              size: 20,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),

                        // Password Field
                        Container(
                          key: _passwordKey,
                          child: AppTextField(
                            label: 'Password',
                            hint: 'Enter your password',
                            controller: _passwordController,
                            focusNode: _passwordFocusNode,
                            isRequired: true,
                            obscureText: true,
                            validator: AppValidators.password,
                            prefixIcon: const Icon(
                              Icons.lock_outline,
                              size: 20,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),

                        // Confirm Password Field
                        Container(
                          key: _confirmPasswordKey,
                          child: AppTextField(
                            label: 'Confirm Password',
                            hint: 'Re-enter your password',
                            controller: _confirmPasswordController,
                            focusNode: _confirmPasswordFocusNode,
                            isRequired: true,
                            obscureText: true,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => _onSignup(),
                            validator: (val) => AppValidators.confirmPassword(
                              val,
                              _passwordController.text,
                            ),
                            prefixIcon: const Icon(
                              Icons.lock_outline,
                              size: 20,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),

                        // Create Account Button
                        AppButton(
                          label: 'Create Account',
                          isLoading: isLoading,
                          onPressed: isLoading ? null : _onSignup,
                        ),
                        const SizedBox(height: AppSpacing.lg),

                        // Navigate to Sign In
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              AppStrings.alreadyHaveAccount,
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondaryLight,
                              ),
                            ),
                            TextButton(
                              onPressed: () => context.go('/login'),
                              child: const Text(
                                'Sign in',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
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
    );
  }
}
