import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:gymbuddy/screens/log_activity_page.dart';
import 'package:gymbuddy/service/planner_service.dart';
import 'log_activity_page_test.mocks.dart';

@GenerateMocks([PlannerService])
void main() {
  late MockPlannerService mockService;

  setUp(() {
    mockService = MockPlannerService();
  });

  // Helper widget wrapper
  Widget createTestWidget() {
    return MaterialApp(home: LogActivityPage(service: mockService));
  }

  // Data Dummy
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
        'is_completed': true, // Sudah selesai
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
        'is_completed': false, // Belum selesai (Tombol muncul disini)
        'completed_at': null,
      },
    ],
  };

  group('LogActivityPage Tests', () {
    testWidgets('UI elements render correctly on load', (
      WidgetTester tester,
    ) async {
      // Stub: Return data dummy
      when(
        mockService.fetchWorkoutLogs(
          any,
          any,
          weekStart: anyNamed('weekStart'),
        ),
      ).thenAnswer((_) async => dummyResponse);

      await tester.pumpWidget(createTestWidget());
      await tester.pump(); // Selesaikan animasi/future

      // 1. Cek Judul
      expect(find.text('Log Latihan Anda'), findsOneWidget);

      // 2. Cek Statistik muncul
      expect(find.text('Statistik Bulan Oktober 2025'), findsOneWidget);
      expect(find.text('40.0%'), findsOneWidget); // Persentase

      // 3. Cek List Item
      expect(find.text('Bench Press'), findsOneWidget);
      expect(find.text('Squat'), findsOneWidget);

      // 4. PERBAIKAN: Cek Tombol 'Selesai' (Hanya yg tipe ElevatedButton)
      // Ini mengatasi error "Found 2 widgets" karena kita spesifik cari tombol
      expect(find.widgetWithText(ElevatedButton, 'Selesai'), findsOneWidget);
    });

    testWidgets('Show empty state when no logs available', (
      WidgetTester tester,
    ) async {
      // Stub: Return list kosong
      when(
        mockService.fetchWorkoutLogs(
          any,
          any,
          weekStart: anyNamed('weekStart'),
        ),
      ).thenAnswer((_) async => {'plans': []});

      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      expect(find.text('Belum Ada Log Latihan'), findsOneWidget);
    });

    testWidgets('Interaction: Mark log as completed', (
      WidgetTester tester,
    ) async {
      // Stub 1: Load awal
      when(
        mockService.fetchWorkoutLogs(
          any,
          any,
          weekStart: anyNamed('weekStart'),
        ),
      ).thenAnswer((_) async => dummyResponse);

      // Stub 2: Saat tombol Simpan ditekan (API completeLog)
      when(mockService.completeLog(any, any)).thenAnswer((_) async => true);

      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // 1. Cari tombol "Selesai" pada item Squat dan KLIK
      final selesaiBtn = find.widgetWithText(ElevatedButton, 'Selesai');
      await tester.tap(selesaiBtn);
      await tester.pumpAndSettle(); // Tunggu dialog muncul

      // 2. Pastikan Dialog muncul
      expect(find.text('Tandai Selesai'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);

      // 3. Isi Catatan
      await tester.enterText(find.byType(TextField), 'Berat banget bro');

      // 4. Klik "Simpan" di dialog
      await tester.tap(find.text('Simpan'));
      await tester.pump();

      // 5. Verifikasi service terpanggil
      verify(mockService.completeLog(2, 'Berat banget bro')).called(1);
    });

    testWidgets('Interaction: Filter changes triggers data fetch', (
      WidgetTester tester,
    ) async {
      when(
        mockService.fetchWorkoutLogs(
          any,
          any,
          weekStart: anyNamed('weekStart'),
        ),
      ).thenAnswer((_) async => {'plans': []});

      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // 1. Buka Dropdown Tahun (Dropdown pertama)
      // Cari dropdown dengan value tahun sekarang (misal 2025 di kode asli kamu)
      // Atau cari berdasarkan tipe
      final dropdowns = find.byType(DropdownButtonFormField<int>);

      // Kita asumsikan Dropdown Tahun adalah yang pertama
      await tester.tap(dropdowns.first);
      await tester.pumpAndSettle();

      // 2. Pilih tahun "2026"
      await tester.tap(find.text('2026').last);
      await tester.pumpAndSettle();

      // 3. Verifikasi fetch terpanggil lagi dengan tahun 2026
      verify(mockService.fetchWorkoutLogs(2026, any, weekStart: any)).called(1);
    });
  });
}
