import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/ui/brand_mark.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/providers/auth_state_provider.dart';
import '../../../../core/utils/coordinator_contact.dart';
import '../../../enrollment/domain/entities/enrollment.dart';
import '../../../enrollment/presentation/providers/enrollment_provider.dart';
import '../../../enrollment/presentation/widgets/semester_card.dart';
import '../../domain/entities/user.dart';
import '../providers/auth_controller.dart';
import '../widgets/step_indicator.dart';
import '../widgets/password_strength_bar.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _step1FormKey = GlobalKey<FormState>();
  final _step2FormKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _studentIdController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  int _stepIndex = 0;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _studentIdController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _nextStep() {
    final openSemester = ref.read(openSemesterProvider);
    final canProceed =
        openSemester.hasError ||
        (openSemester.hasValue && openSemester.value != null);
    if (!canProceed) return;
    if (!_step1FormKey.currentState!.validate()) return;
    setState(() => _stepIndex = 1);
  }

  void _previousStep() {
    setState(() => _stepIndex = 0);
  }

  void _submit() {
    if (!_step2FormKey.currentState!.validate()) return;

    ref
        .read(authControllerProvider.notifier)
        .signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          fullName: _nameController.text.trim(),
          studentId: _studentIdController.text.trim(),
          phone: _phoneController.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    final authCtrl = ref.watch(authControllerProvider);
    final authService = ref.watch(authServiceProvider);
    final openSemester = ref.watch(openSemesterProvider);

    ref.listen(authControllerProvider, (prev, next) {
      next.whenOrNull(
        error: (error, _) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(error.toString())));
        },
        data: (_) {
          context.go(
            '/email-confirmation?email=${_emailController.text.trim()}',
          );
        },
      );
    });

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Center(child: BrandMark(size: 84)),
                const SizedBox(height: 12),
                Text(
                  'Create Account',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                const SizedBox(height: 24),
                StepIndicator(totalSteps: 2, currentStep: _stepIndex),
                const SizedBox(height: 24),
                if (_stepIndex == 0) _buildStep1(authService, openSemester),
                if (_stepIndex == 1) _buildStep2(authCtrl),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => context.go('/login'),
                  child: const Text(
                    'Already have an account? Sign In',
                    style: TextStyle(color: AppColors.primary),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStep1(
    AuthService authService,
    AsyncValue<Enrollment?> openSemester,
  ) {
    final canProceed =
        openSemester.hasError ||
        (openSemester.hasValue && openSemester.value != null);

    return Form(
      key: _step1FormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSemesterPreview(openSemester),
          const SizedBox(height: 20),
          Text('About You', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Full Name',
              prefixIcon: Icon(Icons.person_outlined),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your full name';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _studentIdController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Student ID',
              hintText: '11-digit student ID',
              prefixIcon: Icon(Icons.badge_outlined),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your student ID';
              }
              if (!authService.isValidStudentId(value)) {
                return 'Student ID must be ${AppConstants.studentIdLength} digits';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email',
              hintText: 'you@s.unikl.edu.my',
              prefixIcon: Icon(Icons.email_outlined),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              if (!authService.isValidStudentEmail(value)) {
                return 'Use your @s.unikl.edu.my email';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Phone Number',
              hintText: '9-12 digits',
              prefixIcon: Icon(Icons.phone_outlined),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your phone number';
              }
              if (!authService.isValidPhone(value)) {
                return 'Phone must be 9-12 digits';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: canProceed ? _nextStep : null,
            child: const Text('NEXT'),
          ),
        ],
      ),
    );
  }

  Widget _buildSemesterPreview(AsyncValue<Enrollment?> openSemester) {
    final contact = configuredCoordinatorContact();
    final onContact = contact == null
        ? null
        : () => launchUrl(contact, mode: LaunchMode.externalApplication);

    return openSemester.when(
      loading: () =>
          const SemesterCard(loading: true, title: 'Registering for'),
      error: (error, _) => SemesterCard(
        error: true,
        title: 'Registering for',
        caption:
            "We couldn't check the open INTRA session. You can continue — "
            'your session is assigned when you sign up.',
        onRetry: () => ref.invalidate(openSemesterProvider),
        onContact: onContact,
      ),
      data: (enrollment) => SemesterCard(
        enrollment: enrollment,
        title: 'Registering for',
        emptyLabel: 'No session open for registration',
        caption: enrollment == null
            ? "Registration isn't open for any INTRA session yet. "
                  'Ask your coordinator when to sign up.'
            : "You'll be enrolled in this session automatically.",
        warning: enrollment == null
            ? null
            : 'Not your INTRA session? Contact your coordinator before '
                  'you sign up.',
        onContact: onContact,
      ),
    );
  }

  Widget _buildStep2(AsyncValue<User?> authCtrl) {
    return Form(
      key: _step2FormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Secure Your Account',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              labelText: 'Password',
              prefixIcon: const Icon(Icons.lock_outlined),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
            ),
            onChanged: (_) => setState(() {}),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a password';
              }
              if (value.length < AppConstants.minPasswordLength) {
                return 'Password must be at least ${AppConstants.minPasswordLength} characters';
              }
              return null;
            },
          ),
          PasswordStrengthBar(password: _passwordController.text),
          const SizedBox(height: 16),
          TextFormField(
            controller: _confirmPasswordController,
            obscureText: _obscureConfirm,
            decoration: InputDecoration(
              labelText: 'Confirm Password',
              prefixIcon: const Icon(Icons.lock_outlined),
              suffixIcon:
                  _confirmPasswordController.text.isNotEmpty &&
                      _confirmPasswordController.text ==
                          _passwordController.text
                  ? const Icon(Icons.check_circle, color: AppColors.secondary)
                  : IconButton(
                      icon: Icon(
                        _obscureConfirm
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirm = !_obscureConfirm;
                        });
                      },
                    ),
            ),
            onChanged: (_) => setState(() {}),
            validator: (value) {
              if (value != _passwordController.text) {
                return 'Passwords do not match';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _previousStep,
                  child: const Text('BACK'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: authCtrl.isLoading ? null : _submit,
                  child: authCtrl.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Continue to Sign Up'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
