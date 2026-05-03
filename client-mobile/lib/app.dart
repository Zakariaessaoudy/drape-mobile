import 'package:client_mobile/core/constants/app_constants.dart';
import 'package:client_mobile/shared/widgets/drape_logo.dart';
import 'package:client_mobile/shared/widgets/neon_button.dart';
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
        //had route '/home' ghadi ttbdel b page l'accueil dyal l'application mlli ykmlo l fonctionnalités l'principales.
        '/home': (_) => const _SignedInScreen(),
      },
    );
  }
}

// A simple widget that checks if the user is authenticated and shows either the login screen or a signed-in screen.
// Hadi widget basita katchecki wach lmosta3mil msigni w katban lih login screen ola signed-in screen.
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
              child: CircularProgressIndicator(color: AuthColors.neon),
            ),
          );
        }

        return snapshot.data! ? const _SignedInScreen() : const LoginScreen();
      },
    );
  }
}

// A simple screen shown when the user is signed in, with a logout button.
//in darija: Hadi screen basita katban ila kan lmosta3mil msigni, w fiha bouton dyal logout.
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
            const DrapeLogo(
              size: 46,
              assetPath: 'assets/images/drape_nobg.png',
            ),
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
            SizedBox(
              width: 140,
              child: NeonButton(
                text: 'Logout',
                onPressed: () => _logout(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
