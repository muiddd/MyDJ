import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class TentangAplikasiPage extends StatefulWidget {
  const TentangAplikasiPage({super.key, required this.title});
  final String title;

  @override
  State<TentangAplikasiPage> createState() {
    return _TentangAplikasiPageState();
  }
}

class _TentangAplikasiPageState extends State<TentangAplikasiPage> {
  // Data yang ditampilkan pada halaman Tentang Aplikasi.
  static const String _namaAplikasi = 'MyDJ';
  static const String _deskripsi = 'Aplikasi Jurnal Harian Guru';
  static const String _versi = '1.0.0';
  static const String _pembuat = 'Abdul Muid';
  static const String _url = 'https://www.kemdikbud.go.id';

  Future<void> _bukaUrl() async {
    final Uri uri = Uri.parse(_url);
    final bool berhasil = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );

    if (!berhasil && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak dapat membuka tautan')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/logo_kemdikbud.png',
                  width: 150,
                  height: 150,
                ),
                const SizedBox(height: 16),
                const Text(
                  _namaAplikasi,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  _deskripsi,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 16),
                const Text('Version: $_versi'),
                const SizedBox(height: 8),
                const Text('Dibuat oleh: $_pembuat'),
                const SizedBox(height: 16),
                const Text('Website:'),
                const SizedBox(height: 4),
                InkWell(
                  onTap: _bukaUrl,
                  child: const Text(
                    _url,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
