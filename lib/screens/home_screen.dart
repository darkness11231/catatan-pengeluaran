import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/pengeluaran_provider.dart';
import '../models/pengeluaran.dart';
import 'tambah_pengeluaran_screen.dart';
import 'laporan_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catatan Pengeluaran'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LaporanScreen()),
              );
            },
          ),
        ],
      ),
      body: Consumer<PengeluaranProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              _buildMonthSelector(context, provider),
              _buildTotalCard(context, provider),
              Expanded(
                child: _buildPengeluaranList(context, provider),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const TambahPengeluaranScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildMonthSelector(BuildContext context, PengeluaranProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.blue.shade50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              final newMonth = DateTime(
                provider.selectedMonth.year,
                provider.selectedMonth.month - 1,
              );
              provider.setSelectedMonth(newMonth);
            },
          ),
          Text(
            DateFormat('MMMM yyyy', 'id_ID').format(provider.selectedMonth),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () {
              final newMonth = DateTime(
                provider.selectedMonth.year,
                provider.selectedMonth.month + 1,
              );
              provider.setSelectedMonth(newMonth);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTotalCard(BuildContext context, PengeluaranProvider provider) {
    return FutureBuilder<double>(
      future: provider.getTotalPengeluaran(),
      builder: (context, snapshot) {
        final total = snapshot.data ?? 0;
        final formatter = NumberFormat.currency(
          locale: 'id_ID',
          symbol: 'Rp ',
          decimalDigits: 0,
        );

        return Container(
          width: double.infinity,
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade400, Colors.blue.shade700],
            ),
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Total Pengeluaran',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                formatter.format(total),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPengeluaranList(BuildContext context, PengeluaranProvider provider) {
    if (provider.pengeluaranList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 80,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'Belum ada pengeluaran',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: provider.pengeluaranList.length,
      itemBuilder: (context, index) {
        final pengeluaran = provider.pengeluaranList[index];
        final kategori = provider.getKategoriById(pengeluaran.kategoriId);
        
        return _buildPengeluaranItem(context, provider, pengeluaran, kategori);
      },
    );
  }

  Widget _buildPengeluaranItem(
    BuildContext context,
    PengeluaranProvider provider,
    Pengeluaran pengeluaran,
    kategori,
  ) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: kategori != null
              ? Color(int.parse('0xFF${kategori.warna}')).withOpacity(0.2)
              : Colors.grey.shade200,
          child: Text(
            kategori?.icon ?? '📦',
            style: const TextStyle(fontSize: 24),
          ),
        ),
        title: Text(
          kategori?.nama ?? 'Tidak diketahui',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (pengeluaran.catatan != null && pengeluaran.catatan!.isNotEmpty)
              Text(
                pengeluaran.catatan!,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 13,
                ),
              ),
            const SizedBox(height: 4),
            Text(
              DateFormat('dd MMM yyyy, HH:mm', 'id_ID').format(pengeluaran.tanggal),
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 12,
              ),
            ),
          ],
        ),
        trailing: Text(
          formatter.format(pengeluaran.jumlah),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.red,
          ),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TambahPengeluaranScreen(
                pengeluaran: pengeluaran,
              ),
            ),
          );
        },
        onLongPress: () {
          _showDeleteDialog(context, provider, pengeluaran);
        },
      ),
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    PengeluaranProvider provider,
    Pengeluaran pengeluaran,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Pengeluaran'),
        content: const Text('Apakah Anda yakin ingin menghapus pengeluaran ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              provider.deletePengeluaran(pengeluaran.id!);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Pengeluaran berhasil dihapus')),
              );
            },
            child: const Text(
              'Hapus',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
