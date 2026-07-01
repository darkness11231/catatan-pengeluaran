class Pengeluaran {
  final int? id;
  final double jumlah;
  final int kategoriId;
  final String? catatan;
  final DateTime tanggal;

  Pengeluaran({
    this.id,
    required this.jumlah,
    required this.kategoriId,
    this.catatan,
    required this.tanggal,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'jumlah': jumlah,
      'kategori_id': kategoriId,
      'catatan': catatan,
      'tanggal': tanggal.toIso8601String(),
    };
  }

  factory Pengeluaran.fromMap(Map<String, dynamic> map) {
    return Pengeluaran(
      id: map['id'],
      jumlah: map['jumlah'],
      kategoriId: map['kategori_id'],
      catatan: map['catatan'],
      tanggal: DateTime.parse(map['tanggal']),
    );
  }
}
