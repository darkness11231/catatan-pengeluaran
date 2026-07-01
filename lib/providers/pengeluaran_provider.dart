import 'package:flutter/foundation.dart';
import '../models/pengeluaran.dart';
import '../models/kategori.dart';
import '../database/database_helper.dart';

class PengeluaranProvider with ChangeNotifier {
  List<Pengeluaran> _pengeluaranList = [];
  List<Kategori> _kategoriList = [];
  DateTime _selectedMonth = DateTime.now();
  bool _isLoading = false;

  List<Pengeluaran> get pengeluaranList => _pengeluaranList;
  List<Kategori> get kategoriList => _kategoriList;
  DateTime get selectedMonth => _selectedMonth;
  bool get isLoading => _isLoading;

  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  PengeluaranProvider() {
    loadData();
  }

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    await loadKategori();
    await loadPengeluaran();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadKategori() async {
    _kategoriList = await _dbHelper.getAllKategori();
    notifyListeners();
  }

  Future<void> loadPengeluaran() async {
    _pengeluaranList = await _dbHelper.getPengeluaranByMonth(_selectedMonth);
    notifyListeners();
  }

  Future<void> addPengeluaran(Pengeluaran pengeluaran) async {
    await _dbHelper.createPengeluaran(pengeluaran);
    await loadPengeluaran();
  }

  Future<void> updatePengeluaran(Pengeluaran pengeluaran) async {
    await _dbHelper.updatePengeluaran(pengeluaran);
    await loadPengeluaran();
  }

  Future<void> deletePengeluaran(int id) async {
    await _dbHelper.deletePengeluaran(id);
    await loadPengeluaran();
  }

  void setSelectedMonth(DateTime month) {
    _selectedMonth = month;
    loadPengeluaran();
  }

  Future<double> getTotalPengeluaran() async {
    return await _dbHelper.getTotalPengeluaranByMonth(_selectedMonth);
  }

  Future<Map<int, double>> getPengeluaranByKategori() async {
    return await _dbHelper.getPengeluaranByKategori(_selectedMonth);
  }

  Kategori? getKategoriById(int id) {
    try {
      return _kategoriList.firstWhere((k) => k.id == id);
    } catch (e) {
      return null;
    }
  }
}
