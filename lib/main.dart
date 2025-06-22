import 'package:flutter/material.dart';
import 'package:penyewaan_barang_app/dashboard_barang.dart';

void main() {
  runApp(const PenyewaanApp());
}

class PenyewaanApp extends StatelessWidget {
  const PenyewaanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Penyewaan Barang',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          filled: true,
          fillColor: Colors.grey[50],
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),
      // Halaman pertama yang akan ditampilkan adalah DashboardBarang
      home: const DashboardBarang(),
    );
  }
}
