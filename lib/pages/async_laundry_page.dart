import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'product_detail_page.dart'; // ✅ pastikan file ini ada di folder yang sama

class AsyncLaundryPage extends StatefulWidget {
  final bool useAsyncAwait;

  const AsyncLaundryPage({super.key, required this.useAsyncAwait});

  @override
  State<AsyncLaundryPage> createState() => _AsyncLaundryPageState();
}

class _AsyncLaundryPageState extends State<AsyncLaundryPage> {
  bool isLoading = false;
  String errorMessage = '';
  List<dynamic> produkList = [];

  double? suhuSekarang;
  String? rekomendasiLayanan;
  int? _tappedIndex;

  // ======================================================
  // API LAUNDRY (produk)
  // ======================================================
  Future<List<dynamic>> fetchLaundryData() async {
    final response = await http.get(
      Uri.parse('https://68fc553a96f6ff19b9f4d297.mockapi.io/api/v1/layanan'),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Gagal mengambil data laundry');
    }
  }

  // ======================================================
  // API CUACA
  // ======================================================
  Future<Map<String, dynamic>> fetchWeatherData() async {
    final url = Uri.parse(
        'https://api.open-meteo.com/v1/forecast?latitude=-6.2&longitude=106.8&current=temperature_2m');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Gagal mengambil data cuaca');
    }
  }

  // ======================================================
  // FUNGSI REKOMENDASI (berdasarkan suhu dari API cuaca)
  // ======================================================
  String getRecommendation(double suhu, List<dynamic> layanan) {
    if (suhu > 30) {
      return 'Cuaca panas 🌤️ → Cuci & Keringkan cepat';
    } else if (suhu > 25) {
      return 'Cuaca hangat ☀️ → Gunakan layanan Setrika Saja';
    } else if (suhu > 20) {
      return 'Cuaca sejuk 🌥️ → Gunakan Cuci Lipat';
    } else {
      return 'Cuaca dingin 🌧️ → Gunakan Cuci Selimut';
    }
  }

  // ======================================================
  // Async–await version (API bertingkat)
  // ======================================================
  Future<void> _loadDataAsyncAwait() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    final stopwatch = Stopwatch()..start();
    try {
      // 1️⃣ Ambil data laundry
      final dataLaundry = await fetchLaundryData();

      // 2️⃣ Setelah itu ambil data cuaca
      final cuaca = await fetchWeatherData();

      // 3️⃣ Ambil suhu dan buat rekomendasi
      final suhu = cuaca['current']['temperature_2m'];
      final rekom = getRecommendation(suhu.toDouble(), dataLaundry);

      // 4️⃣ Simpan ke state agar tampil di layar
      setState(() {
        produkList = dataLaundry;
        suhuSekarang = suhu;
        rekomendasiLayanan = rekom;
      });

      print('✅ [Async–Await] Total waktu: ${stopwatch.elapsedMilliseconds} ms');
    } catch (e) {
      setState(() {
        errorMessage = 'Terjadi error: $e';
      });
    } finally {
      stopwatch.stop();
      setState(() => isLoading = false);
    }
  }

  // ======================================================
  // Callback chaining version (API bertingkat)
  // ======================================================
  void _loadDataCallback() {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    final stopwatch = Stopwatch()..start();

    fetchLaundryData().then((dataLaundry) {
      // lanjut ke API cuaca
      fetchWeatherData().then((cuaca) {
        final suhu = cuaca['current']['temperature_2m'];
        final rekom = getRecommendation(suhu.toDouble(), dataLaundry);

        setState(() {
          produkList = dataLaundry;
          suhuSekarang = suhu;
          rekomendasiLayanan = rekom;
          isLoading = false;
        });

        print('✅ [Callback] Total waktu: ${stopwatch.elapsedMilliseconds} ms');
      }).catchError((e) {
        setState(() {
          errorMessage = 'Error cuaca: $e';
          isLoading = false;
        });
      });
    }).catchError((e) {
      setState(() {
        errorMessage = 'Error laundry: $e';
        isLoading = false;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    widget.useAsyncAwait ? _loadDataAsyncAwait() : _loadDataCallback();
  }

  @override
  Widget build(BuildContext context) {
    final mode = widget.useAsyncAwait ? 'Async–Await' : 'Callback Chaining';
    int crossAxisCount = (MediaQuery.of(context).size.width ~/ 180).clamp(2, 4);

    return Scaffold(
      appBar: AppBar(
        title: Text('Laundry $mode'),
        centerTitle: true,
        backgroundColor: Colors.lightBlue,
      ),
      body: Column(
        children: [
          _buildInfoBanner(mode),
          if (suhuSekarang != null && rekomendasiLayanan != null)
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  Text(
                    '🌡️ Suhu Saat Ini: ${suhuSekarang!.toStringAsFixed(1)}°C',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '💡 Rekomendasi: $rekomendasiLayanan',
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.lightBlue))
                : errorMessage.isNotEmpty
                    ? Center(child: Text(errorMessage))
                    : produkList.isEmpty
                        ? const Center(child: Text('Belum ada data layanan.'))
                        : _buildGridProduk(crossAxisCount),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: widget.useAsyncAwait
            ? _loadDataAsyncAwait
            : _loadDataCallback,
        icon: const Icon(Icons.refresh),
        label: const Text('Muat Ulang'),
      ),
    );
  }

  Widget _buildInfoBanner(String mode) {
    return Container(
      padding: const EdgeInsets.all(12),
      color: Colors.blue.withOpacity(0.1),
      child: Row(
        children: [
          const Icon(Icons.info_outline, size: 18, color: Colors.blue),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Menampilkan hasil dari dua API (Laundry + Cuaca) menggunakan $mode',
              style: const TextStyle(fontSize: 12, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridProduk(int crossAxisCount) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: produkList.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 3 / 4,
      ),
      itemBuilder: (context, index) {
        final produk = produkList[index];
        final bool isTapped = _tappedIndex == index;

        final nama = produk['nama'] ?? 'Tanpa nama';
        final deskripsi = produk['deskripsi'] ?? 'Tidak ada deskripsi';
        final id = produk['id'].toString();

        return GestureDetector(
          onTapDown: (_) => setState(() => _tappedIndex = index),
          onTapUp: (_) {
            Future.delayed(const Duration(milliseconds: 150),
                () => setState(() => _tappedIndex = null));

            // ✅ Navigasi ke halaman detail
            Navigator.push(
              context,
              PageRouteBuilder(
                transitionDuration: const Duration(milliseconds: 400),
                pageBuilder: (context, animation, secondaryAnimation) =>
                    ProductDetailPage(
                  productName: nama,
                  description: deskripsi,
                ),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  final fade = CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeInOut,
                  );
                  return FadeTransition(opacity: fade, child: child);
                },
              ),
            );
          },
          onTapCancel: () => setState(() => _tappedIndex = null),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            transform: Matrix4.identity()..scale(isTapped ? 1.05 : 1.0),
            decoration: BoxDecoration(
              color: isTapped
                  ? Colors.lightBlue.shade300
                  : Colors.lightBlue.shade100,
              borderRadius: BorderRadius.circular(isTapped ? 20 : 16),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Hero(
                  tag: id,
                  child: Icon(
                    Icons.local_laundry_service,
                    size: isTapped ? 60 : 50,
                    color: isTapped ? Colors.white : Colors.blueGrey.shade700,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  nama,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: isTapped ? 18 : 16,
                    color: isTapped ? Colors.white : Colors.black87,
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  child: Text(
                    deskripsi,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: isTapped ? Colors.white70 : Colors.black54,
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
}
