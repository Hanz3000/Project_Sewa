class Barang {
  final int id;
  final String namaBarang;
  final String kategori;
  final String status;
  final String tanggal;
  final String gambar; // ✅ tambahkan ini

  Barang({
    required this.id,
    required this.namaBarang,
    required this.kategori,
    required this.status,
    required this.tanggal,
    required this.gambar, // ✅ tambahkan ini
  });

  factory Barang.fromJson(Map<String, dynamic> json) {
    return Barang(
      id: json['id'],
      namaBarang: json['nama_barang'],
      kategori: json['kategori'],
      status: json['status'],
      tanggal: json['tanggal'],
      gambar: json['gambar'], // ✅ parsing dari JSON
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nama_barang': namaBarang,
      'kategori': kategori,
      'status': status,
      'gambar': gambar, // ✅ agar ikut saat upload
    };
  }
}
