import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/barang.dart';

class BarangService {
  static const String baseUrl =
      'http://192.168.56.91:3000/api/barang'; // Ganti IP jika pakai HP asli

  static Future<List<Barang>> fetchBarang() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      List jsonData = json.decode(response.body);
      return jsonData.map((item) => Barang.fromJson(item)).toList();
    } else {
      throw Exception('Gagal memuat data');
    }
  }

  static Future<Barang> tambahBarang(Barang barang) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(barang.toJson()),
    );

    if (response.statusCode == 201) {
      return Barang.fromJson(json.decode(response.body));
    } else {
      throw Exception('Gagal menambahkan barang');
    }
  }
}
