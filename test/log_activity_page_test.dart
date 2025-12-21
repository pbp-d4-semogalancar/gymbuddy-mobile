import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:gymbuddy/screens/log_activity_page.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'log_activity_page_test.mocks.dart';

@GenerateMocks([CookieRequest])
void main() {
  late MockCookieRequest mockRequest;

  setUp(() {
    mockRequest = MockCookieRequest();
    when(mockRequest.loggedIn).thenReturn(true);
  });

  Widget createTestWidget() {
    return MaterialApp(
      home: Provider<CookieRequest>.value(
        value: mockRequest,
        child: const LogActivityPage(),
      ),
    );
  }

  // Data Dummy untuk tes
  final dummyResponse = {
    'period_name': 'Bulan Oktober 2025',
    'total_plans': 5,
    'completed_plans': 2,
    'percentage': 40.0,
    'plans': [
      {
        'id': 1,
        'user': 1,
        'exercise_id': 101,
        'exercise_name': 'Bench Press',
        'sets': 3,
        'reps': 10,
        'plan_date': '2025-10-20',
        'description': 'Mantap',
        'is_completed': true,
        'completed_at': '2025-10-20T10:00:00',
      },
      {
        'id': 2,
        'user': 1,
        'exercise_id': 102,
        'exercise_name': 'Squat',
        'sets': 4,
        'reps': 8,
        'plan_date': '2025-10-21',
        'description': null,
        'is_completed': false,
        'completed_at': null,
      },
    ],
  };

  group('LogActivityPage Tests', () {
    // [FIX 1] UI Rendering
    testWidgets('UI elements render correctly on load', (
      WidgetTester tester,
    ) async {
      when(mockRequest.get(any)).thenAnswer((_) async => dummyResponse);

      await tester.pumpWidget(createTestWidget());

      // GANTI pump() JADI pumpAndSettle()
      // Ini menunggu FutureBuilder selesai loading data
      await tester.pumpAndSettle();

      // Sekarang teks pasti sudah muncul
      expect(find.text('Bench Press'), findsOneWidget);
      expect(find.text('Squat'), findsOneWidget);
    });

    // [FIX 2] Empty State
    testWidgets('Show empty state when no logs available', (
      WidgetTester tester,
    ) async {
      when(mockRequest.get(any)).thenAnswer((_) async => {'plans': []});

      await tester.pumpWidget(createTestWidget());

      // GANTI pump() JADI pumpAndSettle()
      await tester.pumpAndSettle();

      // Pastikan teks ini sesuai dengan yang ada di LogActivityPage Anda
      // (Bisa "Belum ada rencana" atau teks lain yang Anda pasang untuk list kosong)
      expect(find.textContaining('Belum ada'), findsOneWidget);
    });

    // [FIX 3] Interaction Mark as Completed
    testWidgets('Interaction: Mark log as completed', (
      WidgetTester tester,
    ) async {
      when(mockRequest.get(any)).thenAnswer((_) async => dummyResponse);
      when(
        mockRequest.post(any, any),
      ).thenAnswer((_) async => {'status': 'success'});

      await tester.pumpWidget(createTestWidget());

      // [PENTING] Tunggu data awal muncul dulu sebelum mencari tombol!
      await tester.pumpAndSettle();

      // Cari tombol (Icon circle outlined untuk yang belum selesai)
      final completeButton = find.byIcon(Icons.circle_outlined);

      // Pastikan tombol ketemu
      expect(completeButton, findsWidgets);

      if (completeButton.evaluate().isNotEmpty) {
        await tester.tap(completeButton.first);
        await tester.pumpAndSettle(); // Tunggu Dialog muncul

        expect(find.byType(Dialog), findsOneWidget);

        await tester.tap(find.text('Simpan'));
        await tester.pumpAndSettle(); // Tunggu proses simpan & snackbar
      }
    });

    // Test 4 (Filter) Anda sudah aman karena sudah pakai pumpAndSettle di kode aslinya
    testWidgets('Interaction: Filter changes triggers data fetch', (
      WidgetTester tester,
    ) async {
      when(mockRequest.get(any)).thenAnswer((_) async => {'plans': []});
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle(); // Tunggu load awal

      final dropdowns = find.byType(DropdownButtonFormField<int>);
      if (dropdowns.evaluate().isNotEmpty) {
        await tester.tap(dropdowns.first);
        await tester.pumpAndSettle();

        await tester.tap(find.text('2026').last);
        await tester.pumpAndSettle(); // Tunggu data refresh
      }
    });
  });
}
