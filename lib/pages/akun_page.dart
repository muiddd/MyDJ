import 'package:flutter/material.dart';
import 'package:mydj/components/password_field.dart';
import 'package:mydj/data/login_info.dart';
import 'package:mydj/pages/login_page.dart';

class AkunPage extends StatefulWidget {
  const AkunPage({super.key, required this.title});
  final String title;

  @override
  State<AkunPage> createState() {
    return _AkunPageState();
  }
}

class _AkunPageState extends State<AkunPage> {
  String sandiSaatIni = '';
  String sandiBaru = '';
  String konfirmasiSandiBaru = '';

  void _simpanSandi() {
    if (sandiBaru.isEmpty || sandiBaru != konfirmasiSandiBaru) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sandi baru dan konfirmasi tidak sama')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sandi berhasil diubah')),
    );
  }

  void _openLoginPage(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginPage(),
      ),
      (route) => false,
    );
  }

  Future<void> _logout(BuildContext context) async {
    await LoginInfo.deleteFromSharedPreferences();

    if (!context.mounted) return;

    _openLoginPage(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Ganti Sandi',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Divider(thickness: 2),
              const SizedBox(height: 10),
              const Text('Sandi Saat Ini'),
              const SizedBox(height: 10),
              PasswordField(
                onChanged: (value) => setState(() {
                  sandiSaatIni = value;
                }),
              ),
              const SizedBox(height: 10),
              const Text('Sandi Baru'),
              const SizedBox(height: 10),
              PasswordField(
                onChanged: (value) => setState(() {
                  sandiBaru = value;
                }),
              ),
              const SizedBox(height: 10),
              const Text('Konfirmasi Sandi Baru'),
              const SizedBox(height: 10),
              PasswordField(
                onChanged: (value) => setState(() {
                  konfirmasiSandiBaru = value;
                }),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _simpanSandi,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF6750A4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    'Simpan',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),

              const SizedBox(height: 20),
              const Text(
                'Keluar',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Divider(thickness: 2),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    _logout(context);
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF6750A4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    'Keluar dari Aplikasi',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
