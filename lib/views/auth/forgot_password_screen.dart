import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onSend() {
    // TODO: send reset link logic
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Title & description ───────────────────────────────
                const Text(
                  'Recover Password',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Enter your registered email or phone\nnumber to receive a secure reset link\nfor your account.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13.5,
                    color: AppColors.textSecondary,
                    height: 1.55,
                  ),
                ),
                const SizedBox(height: 28),

                // ── Input ─────────────────────────────────────────────
                const Text(
                  'Email or Phone Number',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _controller,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    hintText: 'e.g. hung.nguyen@email.com',
                    prefixIcon: Icon(Icons.alternate_email_rounded, size: 20),
                  ),
                ),
                const SizedBox(height: 24),

                // ── Send button ───────────────────────────────────────
                ElevatedButton(
                  onPressed: _onSend,
                  child: const Text(
                    'Send Reset Link',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(height: 16),

                // ── Back to Login ─────────────────────────────────────
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(
                        Icons.login_rounded,
                        size: 16,
                        color: AppColors.primary,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Back to Login',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
