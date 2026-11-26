import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mydj/components/media_selector.dart';
import 'package:mydj/data/data_provider.dart';
import 'package:mydj/data/jurnal.dart';

class BuatJurnalPage extends StatefulWidget {
  final String title = 'Buat Jurnal';
  final Jurnal? jurnal;

  const BuatJurnalPage({super.key, this.jurnal});

  @override
  State<StatefulWidget> createState() {
    return _BuatJurnalPageState();
  }
}

class _BuatJurnalPageState extends State<BuatJurnalPage> {
  String kelas = '';
  String mapel = '';
  int jamKe = 0;
  String tujuanPembelajaran = '';
  String materiTopikPembelajaran = '';
  String kegiatanPembelajaran = '';
  String dimensiProfilPelajarPancasila = '';

  late final TextEditingController kelasController;
  late final TextEditingController mapelController;
  late final TextEditingController tujuanController;
  late final TextEditingController materiController;
  late final TextEditingController kegiatanController;
  late final TextEditingController dimensiController;

  @override
  void initState() {
    super.initState();

    final Jurnal? jurnal = widget.jurnal;

    kelas = jurnal?.kelas ?? '';
    mapel = jurnal?.mapel ?? '';
    jamKe = jurnal?.jam ?? 0;
    tujuanPembelajaran = jurnal?.tujuanPembelajaran ?? '';
    materiTopikPembelajaran = jurnal?.materiTopikPembelajaran ?? '';
    kegiatanPembelajaran = jurnal?.kegiatanPembelajaran ?? '';
    dimensiProfilPelajarPancasila =
        jurnal?.dimensiProfilPelajarPancasila ?? '';

    kelasController = TextEditingController(text: kelas);
    mapelController = TextEditingController(text: mapel);
    tujuanController = TextEditingController(text: tujuanPembelajaran);
    materiController = TextEditingController(text: materiTopikPembelajaran);
    kegiatanController = TextEditingController(text: kegiatanPembelajaran);
    dimensiController = TextEditingController(
      text: dimensiProfilPelajarPancasila,
    );
  }

  @override
  void dispose() {
    kelasController.dispose();
    mapelController.dispose();
    tujuanController.dispose();
    materiController.dispose();
    kegiatanController.dispose();
    dimensiController.dispose();
    super.dispose();
  }

  Widget _textArea(
    String label,
    String hint,
    TextEditingController controller,
    void Function(String text) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 10),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            labelText: hint,
          ),
          maxLines: 4,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Future<void> _saveJurnal(BuildContext context) async {
    Jurnal jurnal = Jurnal(
      id: widget.jurnal?.id,
      kelas: kelas,
      mapel: mapel,
      jam: jamKe,
      tujuanPembelajaran: tujuanPembelajaran,
      materiTopikPembelajaran: materiTopikPembelajaran,
      kegiatanPembelajaran: kegiatanPembelajaran,
      dimensiProfilPelajarPancasila: dimensiProfilPelajarPancasila,
      createdAt: widget.jurnal?.createdAt,
    );

    DataProvider provider = context.read<DataProvider>();

    if (widget.jurnal == null) {
      await provider.tambahJurnal(jurnal);
    } else {
      await provider.ubahJurnal(jurnal);
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.jurnal == null
                ? 'Jurnal berhasil disimpan'
                : 'Jurnal berhasil diubah',
          ),
        ),
      );

      if (widget.jurnal != null && Navigator.canPop(context)) {
        Navigator.pop(context, jurnal);
      }
    }
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
              const Text('Kelas:'),
              const SizedBox(height: 10),
              TextField(
                controller: kelasController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Masukkan Kelas',
                ),
                onChanged: (value) => setState(() {
                  kelas = value;
                }),
              ),

              const SizedBox(height: 10),
              const Text('Nama Mapel'),
              const SizedBox(height: 10),
              TextField(
                controller: mapelController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Masukkan Nama Mapel',
                ),
                onChanged: (value) => setState(() {
                  mapel = value;
                }),
              ),

              const SizedBox(height: 10),
              const Text('Jam Ke-'),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                initialValue: jamKe == 0 ? null : jamKe.toString(),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Pilih Jam',
                ),
                items: const [
                  DropdownMenuItem(value: '1', child: Text('1')),
                  DropdownMenuItem(value: '2', child: Text('2')),
                  DropdownMenuItem(value: '3', child: Text('3')),
                  DropdownMenuItem(value: '4', child: Text('4')),
                  DropdownMenuItem(value: '5', child: Text('5')),
                  DropdownMenuItem(value: '6', child: Text('6')),
                  DropdownMenuItem(value: '7', child: Text('7')),
                  DropdownMenuItem(value: '8', child: Text('8')),
                ],
                onChanged: (value) => setState(() {
                  jamKe = int.parse(value!);
                }),
              ),

              const SizedBox(height: 10),
              _textArea('Tujuan Pembelajaran', 'Masukkan Tujuan Pembelajaran',
                  tujuanController, (text) => setState(() {
                        tujuanPembelajaran = text;
                      })),
              const SizedBox(height: 10),
              _textArea('Materi/Topik Pembelajaran',
                  'Masukkan Materi/Topik Pembelajaran', materiController,
                  (text) => setState(() {
                        materiTopikPembelajaran = text;
                      })),
              const SizedBox(height: 10),
              _textArea('Kegiatan Pembelajaran', 'Masukkan Kegiatan Pembelajaran',
                  kegiatanController, (text) => setState(() {
                        kegiatanPembelajaran = text;
                      })),
              const SizedBox(height: 10),
              _textArea('Dimensi Profil Pelajar Pancasila',
                  'Tuliskan Dimensi Profil Pelajar Pancasila', dimensiController,
                  (text) => setState(() {
                        dimensiProfilPelajarPancasila = text;
                      })),

              const SizedBox(height: 10),
              const Text('Foto Kegiatan'),
              const SizedBox(height: 10),
              const MediaSelector(), // <-- MediaSelector untuk foto.
              const SizedBox(height: 10),
              const Text('Video Kegiatan'),
              const SizedBox(height: 10),
              const MediaSelector(mediaType: MediaType.video), // <-- Untuk video.

              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _saveJurnal(context),
                  child: const Text('Simpan'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
