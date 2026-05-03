import 'package:client_mobile/app.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('shows login screen when no token is saved', (tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const DrapeApp());
    await tester.pumpAndSettle();

    expect(find.text('Welcome back'), findsOneWidget);
  });
}
