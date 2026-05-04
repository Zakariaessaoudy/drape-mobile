import 'package:client_mobile/features/camera/screens/item_fetch_test_screen.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ItemFetchTestApp());
}

class ItemFetchTestApp extends StatelessWidget {
  const ItemFetchTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Item Fetch Test',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFC7FF00),
          brightness: Brightness.dark,
        ),
      ),
      home: const ItemFetchTestScreen(),
    );
  }
}
