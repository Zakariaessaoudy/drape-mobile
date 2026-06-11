import 'package:client_mobile/core/constants/app_constants.dart';
import 'package:client_mobile/shared/backgrounds/image_background.dart';
import 'package:client_mobile/shared/widgets/auth_text_field.dart';
import 'package:client_mobile/shared/widgets/drape_logo.dart';
import 'package:client_mobile/shared/widgets/field_label.dart';
import 'package:client_mobile/shared/widgets/neon_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/auth_controller.dart';
import 'register_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _error = null);
    final success = await ref
        .read(authControllerProvider.notifier)
        .login(
          email: _emailController.text,
          password: _passwordController.text,
        );

    if (!mounted) return;
    if (success) {
      Navigator.of(context).pushReplacementNamed('/home');
    } else {
      setState(() => _error = ref.read(authControllerProvider).error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loading = ref.watch(authControllerProvider).isLoading;

    return Scaffold(
      backgroundColor: Colors.black,
      body: ImageBackground(
        imagePath: 'assets/images/insane_bg.png',
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 26),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 430),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 30),
                      const Center(
                        child: DrapeLogo(
                          size: 40,
                          assetPath: 'assets/images/drape_nobg.png',
                        ),
                      ),
                      const SizedBox(height: 30),
                      const Text(
                        'Welcome back',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Sign in to your digital wardrobe.',
                        style: TextStyle(
                          color: Color(0xFFB7B7B7),
                          fontSize: 17,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 46),
                      const FieldLabel('EMAIL ADDRESS'),
                      const SizedBox(height: 12),
                      AuthTextField(
                        controller: _emailController,
                        hintText: 'name@couture.com',
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Email is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const FieldLabel('PASSWORD'),
                          TextButton(
                            onPressed: () {},
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const Text(
                              'Forgot Password?',
                              style: TextStyle(
                                color: Color(0xFFB7B7B7),
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      AuthTextField(
                        controller: _passwordController,
                        hintText: '••••••••',
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Password is required';
                          }
                          return null;
                        },
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: 16),
                        Text(
                          _error!,
                          style: const TextStyle(color: Color(0xFFFF6B6B)),
                        ),
                      ],
                      const SizedBox(height: 30),
                      NeonButton(
                        text: 'LOGIN',
                        loading: loading,
                        onPressed: _login,
                      ),
                      const SizedBox(height: 10),
                      const Row(
                        children: [
                          Expanded(child: Divider(color: Color(0xFF171717))),
                          SizedBox(width: 210),
                          Expanded(child: Divider(color: Color(0xFF171717))),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        alignment: WrapAlignment.center,
                        children: [
                          const Text(
                            "Don't have an account? ",
                            style: TextStyle(
                              color: Color(0xFFB7B7B7),
                              fontSize: 15,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => const RegisterScreen(),
                                ),
                              );
                            },
                            child: const Text(
                              'Sign Up',
                              style: TextStyle(
                                color: AuthColors.neon,
                                fontSize: 15,
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
        ),
      ),
    );
  }
}
