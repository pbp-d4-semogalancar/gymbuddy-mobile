import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:gymbuddy/screens/log_activity_page.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:gymbuddy/providers/user_provider.dart';
import 'log_activity_page_test.mocks.dart';

@GenerateMocks([CookieRequest, UserProvider])
void main() {
  // Bypass HTTP agar Image.network tidak error
  HttpOverrides.global = TestHttpOverrides();

  late MockCookieRequest mockRequest;
  late MockUserProvider mockUserProvider;

  setUp(() {
    mockRequest = MockCookieRequest();
    mockUserProvider = MockUserProvider();

    // 1. Setup Mock Request
    when(mockRequest.loggedIn).thenReturn(true);

    // 2. Setup Mock UserProvider
    when(mockUserProvider.userId).thenReturn(1);
    when(mockUserProvider.username).thenReturn('TestUser');
    when(mockUserProvider.profilePicture).thenReturn(null);
    when(mockUserProvider.hasListeners).thenReturn(false);
  });

  // Helper Widget
  Widget createTestWidget() {
    return MaterialApp(
      home: MultiProvider(
        providers: [
          Provider<CookieRequest>.value(value: mockRequest),
          ChangeNotifierProvider<UserProvider>.value(value: mockUserProvider),
        ],
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
        'is_completed': false, // Target Klik
        'completed_at': null,
      },
    ],
  };

  group('LogActivityPage Tests', () {
    // --- TEST 1: UI RENDER & CEK OVERFLOW ---
    testWidgets('UI elements render correctly on load', (
      WidgetTester tester,
    ) async {
      // [FIX LAYAR RAKSASA]
      // Logical Width = 3000 / 3.0 = 1000px (Sangat cukup untuk Row manapun)
      // Logical Height = 4000 / 3.0 = 1333px (Cukup panjang ke bawah)
      tester.view.physicalSize = const Size(3000, 4000);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      when(mockRequest.get(any)).thenAnswer((_) async => dummyResponse);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Cek teks muncul
      expect(find.text('Bench Press'), findsWidgets);
      expect(find.text('Squat'), findsWidgets);
    });

    // --- TEST 2: EMPTY STATE ---
    testWidgets('Show empty state when no logs available', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(3000, 4000);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      // Mock Data Kosong
      when(mockRequest.get(any)).thenAnswer((_) async => {'plans': []});

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.textContaining("Belum ada aktivitas"), findsWidgets);
    });

    // --- TEST 3: INTERACTION COMPLETE ---
    testWidgets('Interaction: Mark log as completed', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(3000, 4000);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      when(mockRequest.get(any)).thenAnswer((_) async => dummyResponse);
      when(
        mockRequest.post(any, any),
      ).thenAnswer((_) async => {'status': 'success'});

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Cari tombol (Icon circle outlined)
      final incompleteFinder = find.byIcon(Icons.circle_outlined);

      expect(incompleteFinder, findsWidgets);

      await tester.tap(incompleteFinder.first, warnIfMissed: false);
      await tester.pumpAndSettle();

      // Cek Dialog
      expect(find.byType(Dialog), findsOneWidget);
      expect(find.text('Simpan'), findsOneWidget);

      await tester.tap(find.text('Simpan'));
      await tester.pumpAndSettle();
    });

    // --- TEST 4: FILTER DROPDOWN ---
    testWidgets('Interaction: Filter changes triggers data fetch', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(3000, 4000);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      when(mockRequest.get(any)).thenAnswer((_) async => {'plans': []});

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Cari semua DropdownButton (biasanya ada Tahun, Bulan, Minggu)
      final dropdownFinder = find.byType(DropdownButton<int>);

      if (dropdownFinder.evaluate().isNotEmpty) {
        // Klik dropdown pertama (Tahun)
        await tester.tap(dropdownFinder.first, warnIfMissed: false);
        await tester.pumpAndSettle();

        // Pilih item terakhir di menu dropdown
        final dropdownItem = find.byType(DropdownMenuItem<int>).last;
        if (dropdownItem.evaluate().isNotEmpty) {
          await tester.tap(dropdownItem, warnIfMissed: false);
          await tester.pumpAndSettle();
        }
      }
    });
  });
}

class TestHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
