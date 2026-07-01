import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/pengeluaran_provider.dart';

class LaporanScreen extends StatelessWidget {
  const LaporanScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan & Statistik'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Consumer<PengeluaranProvider>(
        builder: (context, provider, child) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildMonthSelector(context, provider),
              const SizedBox(height: 20),
              _buildTotalCard(provider),
              const SizedBox(height: 20),
              _buildPieChart(provider),
              const SizedBox(height: 20),
              _buildKategoriList(provider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMonthSelector(BuildContext context, PengeluaranProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
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

  Widget _buildTotalCard(PengeluaranProvider provider) {
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
            children: [
              const Text(
                'Total Pengeluaran',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                formatter.format(total),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${provider.pengeluaranList.length} Transaksi',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPieChart(PengeluaranProvider provider) {
    return FutureBuilder<Map<int, double>>(
      future: provider.getPengeluaranByKategori(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Container(
              height: 250,
              padding: const EdgeInsets.all(20),
              child: Center(
                child: Text(
                  'Belum ada data untuk bulan ini',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          );
        }

        final data = snapshot.data!;
        final total = data.values.fold<double>(0, (sum, val) => sum + val);

        return Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Distribusi Pengeluaran',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 200,
                  child: PieChart(
                    PieChartData(
                      sections: data.entries.map((entry) {
                        final kategori = provider.getKategoriById(entry.key);
                        final percentage = (entry.value / total * 100).toStringAsFixed(1);
                        
                        return PieChartSectionData(
                          value: entry.value,
                          title: '$percentage%',
                          color: kategori != null
                              ? Color(int.parse('0xFF${kategori.warna}'))
                              : Colors.grey,
                          radius: 80,
                          titleStyle: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        );
                      }).toList(),
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildKategoriList(PengeluaranProvider provider) {
    return FutureBuilder<Map<int, double>>(
      future: provider.getPengeluaranByKategori(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }

        final data = snapshot.data!;
        final total = data.values.fold<double>(0, (sum, val) => sum + val);
        final formatter = NumberFormat.currency(
          locale: 'id_ID',
          symbol: 'Rp ',
          decimalDigits: 0,
        );

        final sortedEntries = data.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

        return Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Pengeluaran per Kategori',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ...sortedEntries.map((entry) {
                  final kategori = provider.getKategoriById(entry.key);
                  final percentage = (entry.value / total * 100);

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: kategori != null
                                    ? Color(int.parse('0xFF${kategori.warna}')).withOpacity(0.2)
                                    : Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                kategori?.icon ?? '📦',
                                style: const TextStyle(fontSize: 20),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    kategori?.nama ?? 'Tidak diketahui',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    formatter.format(entry.value),
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '${percentage.toStringAsFixed(1)}%',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: kategori != null
                                    ? Color(int.parse('0xFF${kategori.warna}'))
                                    : Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: percentage / 100,
                            backgroundColor: Colors.grey.shade200,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              kategori != null
                                  ? Color(int.parse('0xFF${kategori.warna}'))
                                  : Colors.grey,
                            ),
                            minHeight: 8,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        );
      },
    );
  }
}
