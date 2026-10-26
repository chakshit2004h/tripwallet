import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/auth/supabase_auth_service.dart';
import '../../../core/data/app_error.dart';
import '../../../core/payment/payment_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/ledger_widgets.dart';
import 'auth_notice.dart';

class AuthFormScreen extends ConsumerStatefulWidget {
  final bool register;
  final String initialEmail;
  const AuthFormScreen({
    super.key,
    this.register = false,
    this.initialEmail = '',
  });
  @override
  ConsumerState<AuthFormScreen> createState() => _AuthFormScreenState();
}

class _AuthFormScreenState extends ConsumerState<AuthFormScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController(),
      _email = TextEditingController(),
      _password = TextEditingController(),
      _vpa = TextEditingController();
  bool _busy = false, _obscure = true;
  String? _message;
  String? _verificationEmail;
  String? _registeredEmail;
  bool _messageIsError = true;

  @override
  void initState() {
    super.initState();
    _email.text = widget.initialEmail;
  }

  void _openSignIn() {
    final next = GoRouterState.of(context).uri.queryParameters['next'];
    context.go(
      Uri(
        path: '/login',
        queryParameters: {
          'email': _registeredEmail ?? _email.text.trim(),
          if (next != null) 'next': next,
        },
      ).toString(),
    );
  }

  void _showMessage(String message, {bool isError = true}) {
    if (!mounted) return;
    setState(() {
      _message = message;
      _messageIsError = isError;
    });
  }

  @override
  void dispose() {
    for (final c in [_name, _email, _password, _vpa]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (_busy || !_form.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    final next =
        GoRouterState.of(context).uri.queryParameters['next'] ?? '/trips';
    setState(() {
      _busy = true;
      _message = null;
      _verificationEmail = null;
      _registeredEmail = null;
    });
    try {
      final auth = ref.read(supabaseAuthServiceProvider);
      if (widget.register) {
        final response = await auth.signUp(
          email: _email.text.trim(),
          password: _password.text,
          displayName: _name.text.trim(),
          paymentVpa: _vpa.text.trim(),
        );
        if (response.session == null) {
          if (mounted) {
            if (ref.read(emailSignupOtpEnabledProvider)) {
              context.push(
                Uri(
                  path: '/verify-email',
                  queryParameters: {'email': _email.text.trim(), 'next': next},
                ).toString(),
              );
            } else {
              _showMessage(
                'Check your email to confirm your account, then sign in.',
                isError: false,
              );
            }
          }
          return;
        }
      } else {
        await auth.signIn(email: _email.text.trim(), password: _password.text);
      }
      if (mounted) {
        context.go(
          next.startsWith('/') && !next.startsWith('//') ? next : '/trips',
        );
      }
    } catch (e) {
      if (mounted &&
          widget.register &&
          e is AuthException &&
          (e.code == 'user_already_exists' || e.code == 'email_exists')) {
        setState(() => _registeredEmail = _email.text.trim());
        _showMessage(
          'This email is already in use. Please sign in to your account.',
        );
        return;
      }
      if (mounted &&
          e is AuthException &&
          e.code == 'email_not_confirmed' &&
          ref.read(emailSignupOtpEnabledProvider)) {
        setState(() => _verificationEmail = _email.text.trim());
      }
      _showMessage(appError(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _reset() async {
    if (!_email.text.contains('@')) {
      _showMessage('Enter your email address first.');
      return;
    }
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      await ref
          .read(supabaseClientProvider)!
          .auth
          .resetPasswordForEmail(
            _email.text.trim(),
            redirectTo: 'tripwallet://auth-callback',
          );
      if (mounted) {
        _showMessage(
          'If this email has an account, you’ll receive a password reset link.',
          isError: false,
        );
      }
    } catch (e) {
      _showMessage(appError(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(),
    body: ContentWidth(
      child: AutofillGroup(
        child: Form(
          key: _form,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.ink,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet_outlined,
                    size: 32,
                    color: AppColors.coral,
                  ),
                ),
              ),
              const SizedBox(height: 28),
              Text(
                widget.register ? 'Your crew starts here.' : 'Welcome back.',
                style: AppTypography.display,
              ),
              const SizedBox(height: 8),
              Text(
                widget.register
                    ? 'Make planning and splitting expenses the easy part.'
                    : 'Your trips, your people, everything in one place.',
                style: AppTypography.bodyLarge,
              ),
              const SizedBox(height: 28),
              if (widget.register) ...[
                TextFormField(
                  controller: _name,
                  maxLength: 80,
                  autofillHints: const [AutofillHints.name],
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(labelText: 'Your name'),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Enter your name' : null,
                ),
                const SizedBox(height: 16),
              ],
              TextFormField(
                controller: _email,
                readOnly: _busy,
                onChanged: (_) {
                  if (_registeredEmail != null || _verificationEmail != null) {
                    setState(() {
                      _registeredEmail = null;
                      _verificationEmail = null;
                      _message = null;
                    });
                  }
                },
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [AutofillHints.email],
                autocorrect: false,
                decoration: InputDecoration(
                  labelText: 'Email address',
                  errorText: _registeredEmail == null
                      ? null
                      : 'Email already in use. Please sign in.',
                  prefixIcon: const Icon(Icons.mail_outline_rounded),
                ),
                validator: (v) =>
                    RegExp(
                      r'^[^\s@]+@[^\s@]+\.[^\s@]+$',
                    ).hasMatch(v?.trim() ?? '')
                    ? null
                    : 'Enter a valid email address',
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _password,
                obscureText: _obscure,
                autofillHints: [
                  widget.register
                      ? AutofillHints.newPassword
                      : AutofillHints.password,
                ],
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                  suffixIcon: IconButton(
                    tooltip: _obscure ? 'Show password' : 'Hide password',
                    onPressed: () => setState(() => _obscure = !_obscure),
                    icon: Icon(
                      _obscure
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                  ),
                ),
                validator: (v) => (v ?? '').length < (widget.register ? 8 : 1)
                    ? (widget.register
                          ? 'Use at least 8 characters'
                          : 'Enter your password')
                    : null,
              ),
              if (widget.register) ...[
                const SizedBox(height: 20),
                TextFormField(
                  controller: _vpa,
                  autocorrect: false,
                  decoration: const InputDecoration(
                    labelText: 'UPI ID (optional)',
                    hintText: 'yourname@bank',
                  ),
                  validator: (v) =>
                      v == null ||
                          v.trim().isEmpty ||
                          PaymentLauncher.validVpa(v.trim())
                      ? null
                      : 'Enter a valid UPI ID',
                ),
              ] else
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _busy ? null : _reset,
                    child: const Text('Forgot password?'),
                  ),
                ),
              if (_message != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: AuthNotice(
                    message: _message!,
                    isError: _messageIsError,
                  ),
                ),
              if (_verificationEmail != null)
                TextButton(
                  onPressed: _busy
                      ? null
                      : () => context.push(
                          Uri(
                            path: '/verify-email',
                            queryParameters: {
                              'email': _verificationEmail!,
                              'sent': 'false',
                              'next':
                                  GoRouterState.of(
                                    context,
                                  ).uri.queryParameters['next'] ??
                                  '/trips',
                            },
                          ).toString(),
                        ),
                  child: const Text('Verify email'),
                ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _busy
                    ? null
                    : _registeredEmail != null
                    ? _openSignIn
                    : _submit,
                child: Text(
                  _busy
                      ? 'Please wait…'
                      : _registeredEmail != null
                      ? 'Sign in'
                      : widget.register
                      ? 'Create account'
                      : 'Sign in',
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: _busy
                    ? null
                    : () {
                        if (widget.register) {
                          _openSignIn();
                          return;
                        }
                        final next = GoRouterState.of(
                          context,
                        ).uri.queryParameters['next'];
                        context.go(
                          Uri(
                            path: widget.register ? '/login' : '/register',
                            queryParameters: next == null
                                ? null
                                : {'next': next},
                          ).toString(),
                        );
                      },
                child: Text(
                  widget.register
                      ? 'Already have an account? Sign in'
                      : 'New here? Create an account',
                ),
              ),
              TextButton(
                onPressed: () => context.push('/privacy'),
                child: const Text('Privacy & your data'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
