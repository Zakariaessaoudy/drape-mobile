import 'package:client_mobile/shared/widgets/drape_logo.dart';
import 'package:flutter/material.dart';

import 'core/storage/token_storage.dart';
import 'features/auth/screens/login_screen.dart';

class DrapeApp extends StatelessWidget {
  const DrapeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Drape',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.black,
        fontFamily: 'Arial',
      ),
      home: const _AuthGate(),
      routes: {
        '/login': (_) => const LoginScreen(),
        '/home': (_) => const _SignedInScreen(),
      },
    );
  }
}

class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: TokenStorage().hasToken(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFFC7FF00)),
            ),
          );
        }

        return snapshot.data! ? const _SignedInScreen() : const LoginScreen();
      },
    );
  }
}

class _SignedInScreen extends StatelessWidget {
  const _SignedInScreen();

  Future<void> _logout(BuildContext context) async {
    await TokenStorage().clearToken();
    if (!context.mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const DrapeLogo(size: 46, assetPath: 'assets/images/drape_logo_no_bg.png'),
            const SizedBox(height: 24),
            const Text(
              'You are signed in',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 24),
            TextButton(
              onPressed: () => _logout(context),
              child: const Text(
                'Log out',
                style: TextStyle(color: Color(0xFFC7FF00)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
