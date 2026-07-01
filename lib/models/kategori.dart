class Kategori {
  final int? id;
  final String nama;
  final String icon;
  final String warna;

  Kategori({
    this.id,
    required this.nama,
    required this.icon,
    required this.warna,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama': nama,
      'icon': icon,
      'warna': warna,
    };
  }

  factory Kategori.fromMap(Map<String, dynamic> map) {
    return Kategori(
      id: map['id'],
      nama: map['nama'],
      icon: map['icon'],
      warna: map['warna'],
    );
  }
}
