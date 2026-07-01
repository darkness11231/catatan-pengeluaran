import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/kategori.dart';
import '../models/pengeluaran.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('pengeluaran.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const doubleType = 'REAL NOT NULL';
    const intType = 'INTEGER NOT NULL';

    // Tabel Kategori
    await db.execute('''
      CREATE TABLE kategori (
        id $idType,
        nama $textType,
        icon $textType,
        warna $textType
      )
    ''');

    // Tabel Pengeluaran
    await db.execute('''
      CREATE TABLE pengeluaran (
        id $idType,
        jumlah $doubleType,
        kategori_id $intType,
        catatan TEXT,
        tanggal $textType,
        FOREIGN KEY (kategori_id) REFERENCES kategori (id)
      )
    ''');

    // Insert kategori default
    await _insertDefaultKategori(db);
  }

  Future _insertDefaultKategori(Database db) async {
    final defaultKategori = [
      {'nama': 'Makanan & Minuman', 'icon': '🍔', 'warna': 'FF5722'},
      {'nama': 'Transport', 'icon': '🚗', 'warna': '2196F3'},
      {'nama': 'Belanja', 'icon': '🛒', 'warna': '9C27B0'},
      {'nama': 'Tagihan', 'icon': '💰', 'warna': 'F44336'},
      {'nama': 'Hiburan', 'icon': '🎮', 'warna': '4CAF50'},
      {'nama': 'Kesehatan', 'icon': '⚕️', 'warna': 'E91E63'},
      {'nama': 'Pendidikan', 'icon': '📚', 'warna': '3F51B5'},
      {'nama': 'Lainnya', 'icon': '📦', 'warna': '607D8B'},
    ];

    for (var kategori in defaultKategori) {
      await db.insert('kategori', kategori);
    }
  }

  // CRUD Kategori
  Future<Kategori> createKategori(Kategori kategori) async {
    final db = await instance.database;
    final id = await db.insert('kategori', kategori.toMap());
    return kategori.copyWith(id: id);
  }

  Future<List<Kategori>> getAllKategori() async {
    final db = await instance.database;
    final result = await db.query('kategori', orderBy: 'nama ASC');
    return result.map((map) => Kategori.fromMap(map)).toList();
  }

  Future<Kategori?> getKategori(int id) async {
    final db = await instance.database;
    final maps = await db.query(
      'kategori',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Kategori.fromMap(maps.first);
    }
    return null;
  }

  // CRUD Pengeluaran
  Future<Pengeluaran> createPengeluaran(Pengeluaran pengeluaran) async {
    final db = await instance.database;
    final id = await db.insert('pengeluaran', pengeluaran.toMap());
    return pengeluaran.copyWith(id: id);
  }

  Future<List<Pengeluaran>> getAllPengeluaran() async {
    final db = await instance.database;
    final result = await db.query('pengeluaran', orderBy: 'tanggal DESC');
    return result.map((map) => Pengeluaran.fromMap(map)).toList();
  }

  Future<List<Pengeluaran>> getPengeluaranByMonth(DateTime month) async {
    final db = await instance.database;
    final startDate = DateTime(month.year, month.month, 1);
    final endDate = DateTime(month.year, month.month + 1, 0, 23, 59, 59);

    final result = await db.query(
      'pengeluaran',
      where: 'tanggal >= ? AND tanggal <= ?',
      whereArgs: [startDate.toIso8601String(), endDate.toIso8601String()],
      orderBy: 'tanggal DESC',
    );

    return result.map((map) => Pengeluaran.fromMap(map)).toList();
  }

  Future<int> updatePengeluaran(Pengeluaran pengeluaran) async {
    final db = await instance.database;
    return db.update(
      'pengeluaran',
      pengeluaran.toMap(),
      where: 'id = ?',
      whereArgs: [pengeluaran.id],
    );
  }

  Future<int> deletePengeluaran(int id) async {
    final db = await instance.database;
    return await db.delete(
      'pengeluaran',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Statistik
  Future<double> getTotalPengeluaranByMonth(DateTime month) async {
    final db = await instance.database;
    final startDate = DateTime(month.year, month.month, 1);
    final endDate = DateTime(month.year, month.month + 1, 0, 23, 59, 59);

    final result = await db.rawQuery('''
      SELECT SUM(jumlah) as total
      FROM pengeluaran
      WHERE tanggal >= ? AND tanggal <= ?
    ''', [startDate.toIso8601String(), endDate.toIso8601String()]);

    return result.first['total'] as double? ?? 0;
  }

  Future<Map<int, double>> getPengeluaranByKategori(DateTime month) async {
    final db = await instance.database;
    final startDate = DateTime(month.year, month.month, 1);
    final endDate = DateTime(month.year, month.month + 1, 0, 23, 59, 59);

    final result = await db.rawQuery('''
      SELECT kategori_id, SUM(jumlah) as total
      FROM pengeluaran
      WHERE tanggal >= ? AND tanggal <= ?
      GROUP BY kategori_id
    ''', [startDate.toIso8601String(), endDate.toIso8601String()]);

    return Map.fromEntries(
      result.map((row) => MapEntry(
            row['kategori_id'] as int,
            row['total'] as double,
          )),
    );
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}

// Extension untuk copyWith
extension KategoriExtension on Kategori {
  Kategori copyWith({
    int? id,
    String? nama,
    String? icon,
    String? warna,
  }) {
    return Kategori(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      icon: icon ?? this.icon,
      warna: warna ?? this.warna,
    );
  }
}

extension PengeluaranExtension on Pengeluaran {
  Pengeluaran copyWith({
    int? id,
    double? jumlah,
    int? kategoriId,
    String? catatan,
    DateTime? tanggal,
  }) {
    return Pengeluaran(
      id: id ?? this.id,
      jumlah: jumlah ?? this.jumlah,
      kategoriId: kategoriId ?? this.kategoriId,
      catatan: catatan ?? this.catatan,
      tanggal: tanggal ?? this.tanggal,
    );
  }
}
