import 'dart:async';
import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/auth/supabase_auth_service.dart';
import '../../../core/data/app_error.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/ledger_widgets.dart';
import 'auth_notice.dart';

class VerifyEmailScreen extends ConsumerStatefulWidget {
  final String email;
  final String next;
  final bool codeJustSent;
  const VerifyEmailScreen({
    super.key,
    required this.email,
    this.next = '/trips',
    this.codeJustSent = true,
  });

  @override
  ConsumerState<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends ConsumerState<VerifyEmailScreen> {
  final _code = TextEditingController();
  final _form = GlobalKey<FormState>();
  Timer? _timer;
  DateTime _resendAt = clock.now().add(const Duration(seconds: 60));
  bool _busy = false;
  bool _resending = false;
  bool _isError = true;
  String? _message;

  int get _seconds => (_resendAt.difference(clock.now()).inMilliseconds / 1000)
      .ceil()
      .clamp(0, 60);

  @override
  void initState() {
    super.initState();
    if (widget.codeJustSent) {
      _startCooldown();
    } else {
      _resendAt = clock.now();
    }
  }

  void _startCooldown() {
    _timer?.cancel();
    _resendAt = clock.now().add(const Duration(seconds: 60));
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {});
      if (_seconds == 0) timer.cancel();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _code.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    if (_busy || !_form.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      await ref
          .read(supabaseAuthServiceProvider)
          .verifySignupCode(email: widget.email, code: _code.text);
      if (mounted) {
        context.go(
          widget.next.startsWith('/') && !widget.next.startsWith('//')
              ? widget.next
              : '/trips',
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _message = appError(e);
          _isError = true;
        });
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _resend() async {
    if (_busy || _seconds > 0) return;
    setState(() {
      _busy = true;
      _resending = true;
      _message = null;
    });
    try {
      await ref
          .read(supabaseAuthServiceProvider)
          .resendSignupCode(widget.email);
      if (mounted) {
        _code.clear();
        _form.currentState?.reset();
        setState(() {
          _message =
              'A new code has been sent. Check your inbox and spam folder.';
          _isError = false;
        });
        _startCooldown();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _message = appError(e);
          _isError = true;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
          _resending = false;
        });
      }
    }
  }

  void _changeEmail() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(
        Uri(
          path: '/register',
          queryParameters: {'next': widget.next},
        ).toString(),
      );
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Verify your email')),
    body: ContentWidth(
      child: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.coralTint,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.mark_email_unread_outlined,
                  size: 34,
                  color: AppColors.ink,
                ),
              ),
            ),
            const SizedBox(height: 28),
            Text('Check your inbox', style: AppTypography.display),
            const SizedBox(height: 12),
            Text(
              'Enter the 6-digit code sent to',
              style: AppTypography.bodyLarge,
            ),
            const SizedBox(height: 4),
            Text(widget.email, style: AppTypography.titleMedium),
            const SizedBox(height: 28),
            TextFormField(
              controller: _code,
              enabled: !_busy,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.oneTimeCode],
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(6),
              ],
              textAlign: TextAlign.center,
              style: AppTypography.display.copyWith(
                letterSpacing: 8,
                fontSize: 28,
              ),
              decoration: const InputDecoration(
                labelText: 'Verification code',
                hintText: '000000',
              ),
              validator: (value) => RegExp(r'^\d{6}$').hasMatch(value ?? '')
                  ? null
                  : 'Enter the 6-digit code from your email.',
              onFieldSubmitted: (_) => _verify(),
            ),
            const SizedBox(height: 12),
            Text(
              'The code expires in 10 minutes. Never share it with anyone.',
              style: AppTypography.bodySmall,
            ),
            if (_message != null)
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: AuthNotice(message: _message!, isError: _isError),
              ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _busy || widget.email.isEmpty ? null : _verify,
              child: Text(
                _busy && !_resending ? 'Verifying…' : 'Verify & continue',
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: _busy || _seconds > 0 || widget.email.isEmpty
                  ? null
                  : _resend,
              child: Text(
                _resending
                    ? 'Sending code…'
                    : _seconds > 0
                    ? 'Resend code in ${_seconds}s'
                    : 'Resend code',
              ),
            ),
            TextButton(
              onPressed: _busy ? null : _changeEmail,
              child: const Text('Change email'),
            ),
            const SizedBox(height: 12),
            Text(
              'Already verified your email?',
              style: AppTypography.bodySmall,
              textAlign: TextAlign.center,
            ),
            TextButton(
              onPressed: _busy
                  ? null
                  : () => context.go(
                      Uri(
                        path: '/login',
                        queryParameters: {'next': widget.next},
                      ).toString(),
                    ),
              child: const Text('Back to sign in'),
            ),
          ],
        ),
      ),
    ),
  );
}
