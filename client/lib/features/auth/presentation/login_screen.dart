import 'package:flutter/material.dart';
import 'auth_form_screen.dart';

class LoginScreen extends StatelessWidget {
  final String initialEmail;
  const LoginScreen({super.key, this.initialEmail = ''});
  @override
  Widget build(BuildContext context) =>
      AuthFormScreen(initialEmail: initialEmail);
}
