// Smoke test untuk halaman-halaman aplikasi MyDJ (Praktikum 07, 08, 10, 11 & 12).
//
// Menguji bahwa SimpleHomePage tampil dengan judul pada AppBar, keempat tombol
// navigasi tersedia, navigasi ke halaman Lihat Jurnal berjalan, penyimpanan
// jurnal ke SQLite lewat DataProvider berjalan, halaman Akun dan Login lengkap
// dengan komponen hasil widget decomposition (PasswordField dan MediaSelector),
// serta sesi login pada Shared Preferences lewat StartupPage.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:mydj/components/media_selector.dart';
import 'package:mydj/components/password_field.dart';
import 'package:mydj/data/data_provider.dart';
import 'package:mydj/data/database_helper.dart';
import 'package:mydj/data/jurnal.dart';
import 'package:mydj/data/login_info.dart';
import 'package:mydj/pages/akun_page.dart';
import 'package:mydj/pages/buat_jurnal_page.dart';
import 'package:mydj/pages/lihat_jurnal_page.dart';
import 'package:mydj/pages/login_page.dart';
import 'package:mydj/pages/simple_home_page.dart';
import 'package:mydj/pages/startup_page.dart';
import 'package:mydj/pages/tentang_aplikasi_page.dart';

Widget _buildApp() {
  return ChangeNotifierProvider(
    create: (context) => DataProvider(),
    child: const MaterialApp(
      home: SimpleHomePage(title: 'Jurnal Harian Guru'),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // sqflite hanya berjalan di Android/iOS, jadi di test (host) kita pakai
  // implementasi FFI agar tabel jurnal tetap bisa diuji.
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  setUp(() async {
    // Setiap test dimulai tanpa sesi login tersimpan.
    SharedPreferences.setMockInitialValues({});

    // Setiap test dimulai dengan tabel jurnal yang kosong.
    final db = await DatabaseHelper.instance.database;
    await db.delete('jurnal');
  });

  testWidgets('SimpleHomePage menampilkan judul dan 4 tombol navigasi',
      (WidgetTester tester) async {
    await tester.pumpWidget(_buildApp());

    // Judul pada AppBar.
    expect(find.text('Jurnal Harian Guru'), findsOneWidget);

    // Empat tombol sesuai jobsheet.
    expect(find.widgetWithText(ElevatedButton, 'Lihat Jurnal'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Buat Jurnal'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Akun'), findsOneWidget);
    expect(
      find.widgetWithText(ElevatedButton, 'Tentang Aplikasi'),
      findsOneWidget,
    );
  });

  testWidgets('Tombol Lihat Jurnal membuka halaman Lihat Jurnal',
      (WidgetTester tester) async {
    await tester.pumpWidget(_buildApp());

    await tester.tap(find.widgetWithText(ElevatedButton, 'Lihat Jurnal'));

    // initState() halaman tujuan memuat jurnal dari SQLite, jadi beri
    // kesempatan operasi async tersebut selesai sebelum test berakhir.
    await tester.runAsync(() async {
      await tester.pump();
      await Future<void>.delayed(const Duration(milliseconds: 500));
    });
    await tester.pumpAndSettle();

    expect(find.byType(ListView), findsOneWidget);
  });

  testWidgets('DataProvider menyimpan jurnal baru ke SQLite',
      (WidgetTester tester) async {
    final provider = DataProvider();

    await tester.runAsync(() async {
      await provider.tambahJurnal(
        Jurnal(kelas: '3A', mapel: 'Bahasa Indonesia'),
      );
    });

    expect(provider.jurnalTersimpan.length, 1);
    expect(provider.jurnalTersimpan.first.kelas, '3A');
    expect(provider.jurnalTersimpan.first.mapel, 'Bahasa Indonesia');
    expect(provider.jurnalTersimpan.first.id, isNotNull);
  });

  testWidgets('DataProvider menghapus jurnal dari SQLite',
      (WidgetTester tester) async {
    final provider = DataProvider();

    await tester.runAsync(() async {
      await provider.tambahJurnal(Jurnal(kelas: '3A', mapel: 'IPA'));
      await provider.tambahJurnal(Jurnal(kelas: '2A', mapel: 'IPS'));

      final int id = provider.jurnalTersimpan.first.id!;
      await provider.hapusJurnal(id);
    });

    expect(provider.jurnalTersimpan.length, 1);
    expect(provider.jurnalTersimpan.first.kelas, '3A');
  });

  testWidgets('Tombol Simpan di Buat Jurnal menambah jurnal ke provider',
      (WidgetTester tester) async {
    // Layar uji dibuat tinggi agar seluruh form (dan tombol Simpan) terlihat.
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (context) => DataProvider(),
        child: const MaterialApp(
          home: BuatJurnalPage(),
        ),
      ),
    );

    await tester.enterText(
      find.widgetWithText(TextField, 'Masukkan Kelas'),
      '4B',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Masukkan Nama Mapel'),
      'IPS',
    );
    final tombolSimpan = find.widgetWithText(ElevatedButton, 'Simpan');

    final context = tester.element(find.byType(BuatJurnalPage));
    final provider = Provider.of<DataProvider>(context, listen: false);

    // Operasi SQLite berjalan di luar zona fake-async, jadi dijalankan
    // lewat runAsync.
    await tester.runAsync(() async {
      await tester.tap(tombolSimpan);
      await Future<void>.delayed(const Duration(milliseconds: 500));
    });

    await tester.pumpAndSettle();

    expect(provider.jurnalTersimpan.length, 1);
    expect(provider.jurnalTersimpan.first.kelas, '4B');
    expect(provider.jurnalTersimpan.first.mapel, 'IPS');
  });

  testWidgets('LihatJurnalPage menampilkan dan menghapus jurnal dari SQLite',
      (WidgetTester tester) async {
    final provider = DataProvider();

    await tester.runAsync(() async {
      await provider.tambahJurnal(
        Jurnal(kelas: '3A', mapel: 'Bahasa Indonesia'),
      );
    });

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: const MaterialApp(
          home: LihatJurnalPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('3A'), findsOneWidget);

    await tester.runAsync(() async {
      await tester.tap(find.byIcon(Icons.delete));
      await Future<void>.delayed(const Duration(milliseconds: 500));
    });
    await tester.pumpAndSettle();

    expect(find.text('3A'), findsNothing);
  });

  testWidgets('BuatJurnalPage menampilkan MediaSelector foto dan video',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (context) => DataProvider(),
        child: const MaterialApp(
          home: BuatJurnalPage(),
        ),
      ),
    );

    expect(find.byType(MediaSelector), findsNWidgets(2));
    expect(find.text('Foto Kegiatan'), findsOneWidget);
    expect(find.text('Video Kegiatan'), findsOneWidget);
  });

  testWidgets('AkunPage menampilkan 3 PasswordField dan 2 tombol',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: AkunPage(title: 'Akun'),
      ),
    );

    expect(find.byType(PasswordField), findsNWidgets(3));
    expect(find.text('Konfirmasi Sandi Baru'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Simpan'), findsOneWidget);
    expect(
      find.widgetWithText(FilledButton, 'Keluar dari Aplikasi'),
      findsOneWidget,
    );
  });

  testWidgets('LoginPage berpindah ke SimpleHomePage dengan kredensial guru',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (context) => DataProvider(),
        child: const MaterialApp(
          home: LoginPage(),
        ),
      ),
    );

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Username'),
      'guru',
    );
    await tester.enterText(find.byType(TextFormField).last, 'guru');
    await tester.pump();

    final tombolLogin = find.widgetWithText(ElevatedButton, 'Login');
    await tester.ensureVisible(tombolLogin);
    await tester.pumpAndSettle();
    await tester.tap(tombolLogin);
    await tester.pumpAndSettle();

    expect(find.byType(SimpleHomePage), findsOneWidget);
    expect(find.text('Beranda'), findsOneWidget);
  });

  testWidgets('Login menyimpan sesi ke Shared Preferences',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (context) => DataProvider(),
        child: const MaterialApp(
          home: LoginPage(),
        ),
      ),
    );

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Username'),
      'guru',
    );
    await tester.enterText(find.byType(TextFormField).last, 'guru');
    await tester.pump();

    final tombolLogin = find.widgetWithText(ElevatedButton, 'Login');
    await tester.ensureVisible(tombolLogin);
    await tester.pumpAndSettle();
    await tester.tap(tombolLogin);
    await tester.pumpAndSettle();

    final LoginInfo? loginInfo = await tester.runAsync(
      () => LoginInfo.fromSharedPreferences(),
    );
    expect(loginInfo!.isLoggedIn, isTrue);
    expect(loginInfo.username, 'guru');
  });

  testWidgets('StartupPage membuka LoginPage ketika belum pernah login',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (context) => DataProvider(),
        child: const MaterialApp(
          home: StartupPage(),
        ),
      ),
    );

    // Saat masih memeriksa sesi, spinner yang tampil.
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pumpAndSettle();

    expect(find.byType(LoginPage), findsOneWidget);
  });

  testWidgets('StartupPage membuka SimpleHomePage ketika sudah login',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({
      'username': 'guru',
      'password': 'guru',
      'isLoggedIn': true,
    });

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (context) => DataProvider(),
        child: const MaterialApp(
          home: StartupPage(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(SimpleHomePage), findsOneWidget);
  });

  testWidgets('Logout menghapus sesi dan kembali ke LoginPage',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({
      'username': 'guru',
      'password': 'guru',
      'isLoggedIn': true,
    });

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (context) => DataProvider(),
        child: const MaterialApp(
          home: AkunPage(title: 'Akun'),
        ),
      ),
    );

    await tester.tap(
      find.widgetWithText(FilledButton, 'Keluar dari Aplikasi'),
    );
    await tester.pumpAndSettle();

    final LoginInfo loginInfo = await LoginInfo.fromSharedPreferences();
    expect(loginInfo.isLoggedIn, isFalse);
    expect(find.byType(LoginPage), findsOneWidget);
  });

  testWidgets('TentangAplikasiPage menampilkan nama, versi, pembuat, dan URL',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: TentangAplikasiPage(title: 'Tentang Aplikasi'),
      ),
    );

    expect(find.text('MyDJ'), findsOneWidget);
    expect(find.text('Aplikasi Jurnal Harian Guru'), findsOneWidget);
    expect(find.text('Version: 1.0.0'), findsOneWidget);
    expect(find.text('Dibuat oleh: Abdul Muid'), findsOneWidget);

    // URL harus bisa di-tap (dibungkus InkWell) untuk membuka browser.
    expect(find.byType(InkWell), findsOneWidget);
    expect(find.textContaining('https://'), findsOneWidget);
  });
}
