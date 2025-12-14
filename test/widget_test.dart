import 'package:flutter_test/flutter_test.dart';
import 'package:gymbuddy/main.dart'; // Sesuaikan path package
import 'package:gymbuddy/screens/login.dart'; // Sesuaikan path package

void main() {
  testWidgets('Aplikasi harus memuat LoginPage saat pertama kali dibuka', (
    WidgetTester tester,
  ) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verifikasi bahwa LoginPage muncul
    expect(find.byType(LoginPage), findsOneWidget);

    // Opsional: Cek teks yang pasti ada di Login Page, misal "Login"
    // expect(find.text('Login'), findsAtLeastNWidgets(1));
  });
}
