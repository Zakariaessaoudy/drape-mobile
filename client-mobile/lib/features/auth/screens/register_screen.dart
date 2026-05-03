import 'package:client_mobile/shared/widgets/drape_logo.dart';
import 'package:flutter/material.dart';

import '../data/auth_api.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authApi = AuthApi();

  bool _acceptedTerms = false;
  bool _showPassword = false;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_acceptedTerms) {
      setState(() => _error = 'Please accept the terms to continue');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await _authApi.register(
        name: _nameController.text,
        email: _emailController.text,
        password: _passwordController.text,
      );
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/home');
    } on AuthException catch (error) {
      setState(() => _error = error.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          const Positioned.fill(child: _SignupBackground()),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 430),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Center(
                        child: DrapeLogo(
                          size: 40,
                          assetPath: 'assets/images/drape_nobg.png',
                        ),
                      ),
                      const SizedBox(height: 66),
                      RichText(
                        text: const TextSpan(
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 38,
                            fontWeight: FontWeight.w900,
                            height: 0.98,
                          ),
                          children: [
                            TextSpan(text: 'Join the\n'),
                            TextSpan(
                              text: 'Future\n',
                              style: TextStyle(color: AuthColors.neon),
                            ),
                            TextSpan(text: 'of Fashion'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 84),
                      Container(
                        padding: const EdgeInsets.fromLTRB(30, 36, 30, 30),
                        decoration: BoxDecoration(
                          color: const Color(
                            0xFF111111,
                          ).withValues(alpha: 0.94),
                          borderRadius: BorderRadius.circular(26),
                          border: Border.all(color: const Color(0xFF242424)),
                          boxShadow: [
                            BoxShadow(
                              color: AuthColors.neon.withValues(alpha: 0.13),
                              blurRadius: 34,
                              offset: const Offset(0, 18),
                            ),
                          ],
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(left: 36),
                                child: FieldLabel('FULL NAME'),
                              ),
                              const SizedBox(height: 12),
                              AuthTextField(
                                controller: _nameController,
                                hintText: 'ALEXANDER VOGUE',
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Name is required';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 26),
                              const Padding(
                                padding: EdgeInsets.only(left: 36),
                                child: FieldLabel('EMAIL ADDRESS'),
                              ),
                              const SizedBox(height: 12),
                              AuthTextField(
                                controller: _emailController,
                                hintText: 'identity@drape.style',
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Email is required';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 26),
                              const Padding(
                                padding: EdgeInsets.only(left: 36),
                                child: FieldLabel('PASSWORD'),
                              ),
                              const SizedBox(height: 12),
                              AuthTextField(
                                controller: _passwordController,
                                hintText: '••••••••••••',
                                obscureText: !_showPassword,
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    setState(
                                      () => _showPassword = !_showPassword,
                                    );
                                  },
                                  icon: Icon(
                                    _showPassword
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    color: const Color(0xFFB7B7B7),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.length < 8) {
                                    return 'Password must be at least 8 characters';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 26),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: 28,
                                    height: 28,
                                    child: Checkbox(
                                      value: _acceptedTerms,
                                      onChanged: (value) {
                                        setState(
                                          () => _acceptedTerms = value ?? false,
                                        );
                                      },
                                      side: const BorderSide(
                                        color: Color(0xFF777777),
                                        width: 1.4,
                                      ),
                                      activeColor: AuthColors.neon,
                                      checkColor: Colors.black,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  const Expanded(
                                    child: Text.rich(
                                      TextSpan(
                                        style: TextStyle(
                                          color: Color(0xFFB7B7B7),
                                          fontSize: 15,
                                          height: 1.25,
                                        ),
                                        children: [
                                          TextSpan(text: 'I agree to the '),
                                          TextSpan(
                                            text: 'Terms of Service',
                                            style: TextStyle(
                                              color: Colors.white,
                                              decoration:
                                                  TextDecoration.underline,
                                            ),
                                          ),
                                          TextSpan(text: ' and '),
                                          TextSpan(
                                            text: 'Privacy\nPolicy',
                                            style: TextStyle(
                                              color: Colors.white,
                                              decoration:
                                                  TextDecoration.underline,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (_error != null) ...[
                                const SizedBox(height: 16),
                                Text(
                                  _error!,
                                  style: const TextStyle(
                                    color: Color(0xFFFF6B6B),
                                  ),
                                ),
                              ],
                              const SizedBox(height: 42),
                              NeonButton(
                                text: 'CREATE ACCOUNT',
                                loading: _loading,
                                onPressed: _register,
                              ),
                              const SizedBox(height: 42),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    'Already have an account? ',
                                    style: TextStyle(
                                      color: Color(0xFFB7B7B7),
                                      fontSize: 15,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => Navigator.of(context).pop(),
                                    child: const Text(
                                      'Log In',
                                      style: TextStyle(
                                        color: AuthColors.neon,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Center(
                        child: Text(
                          'SECURE ENCRYPTION',
                          style: TextStyle(
                            color: Color(0xFF313131),
                            fontSize: 11,
                            letterSpacing: 6,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// class _SignupBackground extends StatelessWidget {
//   const _SignupBackground();

//   @override
//   Widget build(BuildContext context) {
//     // 1. Added SizedBox.expand to force the background to fill the screen
//     return SizedBox.expand(
//       child: DecoratedBox(
//         decoration: const BoxDecoration(
//           gradient: RadialGradient(
//             center: Alignment(0.25, -0.2),
//             radius: 0.9,
//             colors: [Color(0xFF14332B), Color(0xFF050706), Colors.black],
//           ),
//         ),
//       ),
//     );
//   }
// }
class _SignupBackground extends StatelessWidget {
  const _SignupBackground();

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Stack(
        children: [
          // 1. Base Gradient: Smoothed out the stops for a richer transition
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0.3, -0.4),
                  radius: 1.2,
                  colors: [
                    Color(0xFF1A4237), // Slightly brighter inner core
                    Color(0xFF091410), // Deep forest/emerald mid-tone
                    Colors.black, // True black at the edges
                  ],
                  stops: [0.0, 0.5, 1.0], // Controls the falloff smoothly
                ),
              ),
            ),
          ),

          // 2. Ambient Glow: Creates a "neon light off-screen" effect
          Positioned(
            top: -60,
            right: -80,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    // Replace with your AuthColors.neon if you have it!
                    color: const Color(0xFF00FF7F).withValues(alpha: 0.08),
                    blurRadius: 100,
                    spreadRadius: 40,
                  ),
                ],
              ),
            ),
          ),

          // 3. Bottom Vignette: Crucial for UI readability
          // Fades the bottom of the screen to deep black so buttons/text pop
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.2),
                    Colors.black.withValues(alpha: 0.85),
                  ],
                  stops: const [
                    0.6,
                    0.85,
                    1.0,
                  ], // Pushes the dark fade to the very bottom
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
