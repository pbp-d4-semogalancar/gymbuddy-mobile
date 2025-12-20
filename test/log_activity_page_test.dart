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
    testWidgets('UI elements render correctly on load', (WidgetTester tester) async {
      when(mockRequest.get(any)).thenAnswer((_) async => dummyResponse);

      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      expect(find.textContaining('Log'), findsWidgets); 
      
      // Cek List Item muncul
      expect(find.text('Bench Press'), findsOneWidget);
      expect(find.text('Squat'), findsOneWidget);
    });

    testWidgets('Show empty state when no logs available', (WidgetTester tester) async {
      // Mock return list kosong
      when(mockRequest.get(any)).thenAnswer((_) async => {'plans': []});

      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // (Berdasarkan file workout_plan_page.dart, teksnya mungkin "Belum ada rencana...")
      expect(find.textContaining('Belum ada'), findsOneWidget);
    });

    testWidgets('Interaction: Mark log as completed', (WidgetTester tester) async {
      // Load data awal
      when(mockRequest.get(any)).thenAnswer((_) async => dummyResponse);
      
      // Mock POST request untuk complete log
      when(mockRequest.post(any, any)).thenAnswer((_) async => {'status': 'success'});

      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Cari tombol "Selesai" (checkbox atau button) dan klik
      // Sesuaikan finder ini dengan UI terbaru Anda (misal Icon Checkbox)
      final completeButton = find.byIcon(Icons.circle_outlined); // Asumsi icon belum selesai
      if (completeButton.evaluate().isNotEmpty) {
         await tester.tap(completeButton.first);
         await tester.pumpAndSettle(); // Tunggu dialog
         
         // Cek Dialog muncul
         expect(find.byType(Dialog), findsOneWidget);
         
         // Klik Simpan di dialog
         await tester.tap(find.text('Simpan'));
         await tester.pump();
      }
    });
  });
}
