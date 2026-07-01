import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/pengeluaran_provider.dart';
import '../models/pengeluaran.dart';
import '../models/kategori.dart';

class TambahPengeluaranScreen extends StatefulWidget {
  final Pengeluaran? pengeluaran;

  const TambahPengeluaranScreen({Key? key, this.pengeluaran}) : super(key: key);

  @override
  State<TambahPengeluaranScreen> createState() => _TambahPengeluaranScreenState();
}

class _TambahPengeluaranScreenState extends State<TambahPengeluaranScreen> {
  final _formKey = GlobalKey<FormState>();
  final _jumlahController = TextEditingController();
  final _catatanController = TextEditingController();
  
  Kategori? _selectedKategori;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  @override
  void initState() {
    super.initState();
    if (widget.pengeluaran != null) {
      _jumlahController.text = widget.pengeluaran!.jumlah.toString();
      _catatanController.text = widget.pengeluaran!.catatan ?? '';
      _selectedDate = widget.pengeluaran!.tanggal;
      _selectedTime = TimeOfDay.fromDateTime(widget.pengeluaran!.tanggal);
    }
  }

  @override
  void dispose() {
    _jumlahController.dispose();
    _catatanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PengeluaranProvider>(context);
    
    // Set kategori awal jika edit
    if (widget.pengeluaran != null && _selectedKategori == null) {
      _selectedKategori = provider.getKategoriById(widget.pengeluaran!.kategoriId);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.pengeluaran == null ? 'Tambah Pengeluaran' : 'Edit Pengeluaran'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildJumlahField(),
            const SizedBox(height: 20),
            _buildKategoriSelector(provider),
            const SizedBox(height: 20),
            _buildDateSelector(),
            const SizedBox(height: 20),
            _buildTimeSelector(),
            const SizedBox(height: 20),
            _buildCatatanField(),
            const SizedBox(height: 30),
            _buildSubmitButton(provider),
          ],
        ),
      ),
    );
  }

  Widget _buildJumlahField() {
    return TextFormField(
      controller: _jumlahController,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(
        labelText: 'Jumlah',
        prefixText: 'Rp ',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Jumlah tidak boleh kosong';
        }
        if (double.tryParse(value) == null || double.parse(value) <= 0) {
          return 'Jumlah harus lebih dari 0';
        }
        return null;
      },
    );
  }

  Widget _buildKategoriSelector(PengeluaranProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Kategori',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: _selectedKategori == null ? Colors.red : Colors.grey.shade300,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1,
            ),
            itemCount: provider.kategoriList.length,
            itemBuilder: (context, index) {
              final kategori = provider.kategoriList[index];
              final isSelected = _selectedKategori?.id == kategori.id;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedKategori = kategori;
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Color(int.parse('0xFF${kategori.warna}'))
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? Color(int.parse('0xFF${kategori.warna}'))
                          : Colors.grey.shade300,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        kategori.icon,
                        style: const TextStyle(fontSize: 28),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        kategori.nama,
                        style: TextStyle(
                          fontSize: 10,
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        if (_selectedKategori == null)
          const Padding(
            padding: EdgeInsets.only(top: 8, left: 12),
            child: Text(
              'Pilih kategori',
              style: TextStyle(
                color: Colors.red,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDateSelector() {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _selectedDate,
          firstDate: DateTime(2020),
          lastDate: DateTime(2100),
        );
        if (picked != null) {
          setState(() {
            _selectedDate = picked;
          });
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Tanggal',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
          suffixIcon: const Icon(Icons.calendar_today),
        ),
        child: Text(
          DateFormat('dd MMMM yyyy', 'id_ID').format(_selectedDate),
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildTimeSelector() {
    return InkWell(
      onTap: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: _selectedTime,
        );
        if (picked != null) {
          setState(() {
            _selectedTime = picked;
          });
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Waktu',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
          suffixIcon: const Icon(Icons.access_time),
        ),
        child: Text(
          _selectedTime.format(context),
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildCatatanField() {
    return TextFormField(
      controller: _catatanController,
      maxLines: 3,
      decoration: InputDecoration(
        labelText: 'Catatan (opsional)',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        alignLabelWithHint: true,
      ),
    );
  }

  Widget _buildSubmitButton(PengeluaranProvider provider) {
    return ElevatedButton(
      onPressed: () => _submitForm(provider),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Text(
        widget.pengeluaran == null ? 'Simpan' : 'Update',
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _submitForm(PengeluaranProvider provider) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedKategori == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih kategori terlebih dahulu')),
      );
      return;
    }

    final jumlah = double.parse(_jumlahController.text);
    final catatan = _catatanController.text.isEmpty ? null : _catatanController.text;
    
    final tanggal = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    final pengeluaran = Pengeluaran(
      id: widget.pengeluaran?.id,
      jumlah: jumlah,
      kategoriId: _selectedKategori!.id!,
      catatan: catatan,
      tanggal: tanggal,
    );

    try {
      if (widget.pengeluaran == null) {
        await provider.addPengeluaran(pengeluaran);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Pengeluaran berhasil ditambahkan')),
          );
        }
      } else {
        await provider.updatePengeluaran(pengeluaran);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Pengeluaran berhasil diupdate')),
          );
        }
      }
      
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }
}
