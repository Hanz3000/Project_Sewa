import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:http/http.dart' as http;

class FormPenyewaan extends StatefulWidget {
  final Map<String, dynamic>? barang;

  const FormPenyewaan({Key? key, this.barang}) : super(key: key);

  @override
  _FormPenyewaanState createState() => _FormPenyewaanState();
}

class _FormPenyewaanState extends State<FormPenyewaan> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController namaController = TextEditingController();
  String? kategori;
  String status = 'masuk';

  File? _imageFile;
  final picker = ImagePicker();
  String? _gambarLama;

  List<String> kategoriList = [
    'Komputer',
    'Laptop',
    'Proyektor',
    'Printer',
    'Lainnya',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.barang != null) {
      namaController.text = widget.barang!['nama_barang'];
      kategori = widget.barang!['kategori'];
      status = widget.barang!['status'];
      _gambarLama = widget.barang!['gambar'];
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final isEdit = widget.barang != null;
      final url = isEdit
          ? 'http://192.168.56.91:3000/api/barang/${widget.barang!['id']}'
          : 'http://192.168.56.91:3000/api/barang';

      final request = http.MultipartRequest(
        isEdit ? 'PUT' : 'POST',
        Uri.parse(url),
      );

      request.fields['nama_barang'] = namaController.text;
      request.fields['kategori'] = kategori!;
      request.fields['status'] = status;

      if (_imageFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'gambar',
            _imageFile!.path,
            filename: p.basename(_imageFile!.path),
          ),
        );
      } else if (isEdit && _gambarLama != null) {
        request.fields['gambar'] = _gambarLama!;
      }

      try {
        final response = await request.send();

        if (response.statusCode == 200 || response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isEdit
                    ? '✅ Data berhasil diperbarui'
                    : '✅ Data berhasil disimpan',
              ),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('❌ Gagal menyimpan data'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        print("Error: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Terjadi error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.barang != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Barang' : 'Tambah Barang'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: namaController,
                decoration: const InputDecoration(
                  labelText: 'Nama Barang',
                  prefixIcon: Icon(Icons.inventory),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Nama barang wajib diisi' : null,
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Kategori',
                  prefixIcon: Icon(Icons.category),
                ),
                value: kategori,
                items: kategoriList.map((kat) {
                  return DropdownMenuItem(value: kat, child: Text(kat));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    kategori = value!;
                  });
                },
                validator: (value) => value == null ? 'Pilih kategori' : null,
              ),
              const SizedBox(height: 20),
              const Text('Status Barang:'),
              Row(
                children: [
                  ChoiceChip(
                    label: const Text('Masuk'),
                    selected: status == 'masuk',
                    onSelected: (_) => setState(() => status = 'masuk'),
                    selectedColor: Colors.indigo,
                    labelStyle: TextStyle(
                      color: status == 'masuk' ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(width: 10),
                  ChoiceChip(
                    label: const Text('Keluar'),
                    selected: status == 'keluar',
                    onSelected: (_) => setState(() => status = 'keluar'),
                    selectedColor: Colors.indigo,
                    labelStyle: TextStyle(
                      color: status == 'keluar' ? Colors.white : Colors.black,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text('Upload Foto Barang'),
              const SizedBox(height: 10),
              if (_imageFile != null)
                Image.file(_imageFile!, height: 150)
              else if (_gambarLama != null)
                Image.network(
                  'http://192.168.56.91:3000/uploads/$_gambarLama',
                  height: 150,
                  errorBuilder: (context, error, stackTrace) =>
                      const Text('Gagal memuat gambar'),
                )
              else
                const Text('Belum ada gambar dipilih.'),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.image),
                label: const Text('Pilih Gambar'),
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: _submitForm,
                icon: Icon(isEdit ? Icons.update : Icons.save),
                label: Text(isEdit ? 'Perbarui Data' : 'Simpan Data'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
