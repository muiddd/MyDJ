import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mydj/data/data_provider.dart';
import 'package:mydj/data/jurnal.dart';
import 'package:mydj/pages/buat_jurnal_page.dart';

class DetailJurnalPage extends StatefulWidget {
  const DetailJurnalPage({super.key, required this.jurnal});

  final Jurnal jurnal;
  final String title = 'Detail Jurnal';

  @override
  State<DetailJurnalPage> createState() {
    return _DetailJurnalPageState();
  }
}

class _DetailJurnalPageState extends State<DetailJurnalPage> {
  late Jurnal _jurnal = widget.jurnal;

  Jurnal _jurnalTampil() {
    final DataProvider? provider =
        Provider.of<DataProvider?>(context, listen: false);
    if (provider != null) {
      for (final Jurnal jurnal in provider.jurnalTersimpan) {
        if (jurnal.id == widget.jurnal.id) {
          return jurnal;
        }
      }
    }
    return _jurnal;
  }

  Widget _baris(String label, String nilai) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          Text(nilai),
        ],
      ),
    );
  }

  Future<void> _openEditJurnalPage(Jurnal jurnal) async {
    final Jurnal? hasil = await Navigator.push<Jurnal>(
      context,
      MaterialPageRoute(builder: (context) => BuatJurnalPage(jurnal: jurnal)),
    );

    if (hasil != null && mounted) {
      setState(() {
        _jurnal = hasil;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Jurnal jurnal = _jurnalTampil();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _openEditJurnalPage(jurnal),
                  child: const Text('Edit Jurnal Ini'),
                ),
              ),
              const SizedBox(height: 20),
              _baris('Kelas', jurnal.kelas),
              _baris('Mata Pelajaran', jurnal.mapel),
              _baris('Jam Ke-', jurnal.jam.toString()),
              _baris('Tujuan Pembelajaran', jurnal.tujuanPembelajaran),
              _baris(
                'Materi / Topik Pembelajaran',
                jurnal.materiTopikPembelajaran,
              ),
              _baris('Kegiatan Pembelajaran', jurnal.kegiatanPembelajaran),
              _baris(
                'Dimensi Profil Pelajar Pancasila',
                jurnal.dimensiProfilPelajarPancasila,
              ),
              _baris('Waktu Dibuat', jurnal.createdAt.toString()),
            ],
          ),
        ),
      ),
    );
  }
}
