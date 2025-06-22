import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:penyewaan_barang_app/form_penyewaan.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class DashboardBarang extends StatefulWidget {
  const DashboardBarang({super.key});

  @override
  State<DashboardBarang> createState() => _DashboardBarangState();
}

class _DashboardBarangState extends State<DashboardBarang> {
  List<dynamic> _data = [];
  bool _isLoading = true;
  String _error = '';
  late WebSocketChannel _channel;

  @override
  void initState() {
    super.initState();
    _fetchData();

    // ✅ WebSocket listen untuk realtime update
    _channel = WebSocketChannel.connect(
      Uri.parse('ws://192.168.56.91:8080'), // ganti IP sesuai server
    );

    _channel.stream.listen((message) {
      if (message == 'barang_updated') {
        _fetchData();
      }
    });
  }

  @override
  void dispose() {
    _channel.sink.close();
    super.dispose();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });
    try {
      final response = await http.get(
        Uri.parse('http://192.168.56.91:3000/api/barang'),
      );

      if (response.statusCode == 200) {
        setState(() {
          _data = jsonDecode(response.body);
          _isLoading = false;
        });
      } else {
        throw Exception('Gagal mengambil data: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _error = 'Terjadi kesalahan: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _hapusBarang(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('http://192.168.56.91:3000/api/barang/$id'),
      );
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Barang berhasil dihapus')),
        );
        _fetchData(); // tetap fetch agar cepat update di local
      } else {
        throw Exception('Gagal menghapus barang');
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Terjadi kesalahan: $e')));
    }
  }

  void _konfirmasiHapus(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: const Text('Apakah kamu yakin ingin menghapus barang ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              _hapusBarang(id);
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  IconData _getIconForCategory(String? kategori) {
    switch (kategori) {
      case 'Komputer':
        return Icons.computer;
      case 'Laptop':
      case 'Notebook':
        return Icons.laptop;
      case 'Proyektor':
        return Icons.videocam;
      case 'Printer':
        return Icons.print;
      case 'Monitor':
        return Icons.monitor;
      default:
        return Icons.devices_other;
    }
  }

  Color _getStatusColor(String? status) {
    if (status == 'masuk') return Colors.green;
    if (status == 'keluar') return Colors.orange;
    return Colors.grey;
  }

  String _getStatusText(String? status) {
    if (status == 'masuk') return 'Tersedia';
    if (status == 'keluar') return 'Keluar';
    return 'Tidak Diketahui';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Barang'), centerTitle: true),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
          ? Center(child: Text(_error))
          : _data.isEmpty
          ? const Center(child: Text('Belum Ada Barang'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _data.length,
              itemBuilder: (context, index) {
                final item = _data[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    leading: item['gambar'] != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              'http://192.168.56.91:3000/uploads/${item['gambar']}',
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(
                                    Icons.broken_image,
                                    color: Colors.grey,
                                  ),
                            ),
                          )
                        : Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.indigo.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _getIconForCategory(item['kategori']),
                              color: Colors.indigo,
                            ),
                          ),
                    title: Text(
                      item['nama_barang'] ?? 'Tanpa Nama',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          'Kategori: ${item['kategori'] ?? 'Tidak Diketahui'}',
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: _getStatusColor(
                                  item['status'],
                                ).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                _getStatusText(item['status']),
                                style: TextStyle(
                                  color: _getStatusColor(item['status']),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              item['tanggal'] != null
                                  ? DateTime.parse(
                                      item['tanggal'],
                                    ).toLocal().toString().substring(0, 10)
                                  : '',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    FormPenyewaan(barang: item),
                              ),
                            );
                            _fetchData();
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            _konfirmasiHapus(item['id']);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const FormPenyewaan()),
          );
          _fetchData();
        },
        backgroundColor: Colors.indigo,
        child: const Icon(Icons.add),
      ),
    );
  }
}
