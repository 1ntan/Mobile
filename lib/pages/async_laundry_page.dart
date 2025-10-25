import 'package:flutter/material.dart';
import '../services/http_service.dart';
import 'product_detail_page.dart'; // halaman detail produk

class AsyncLaundryPage extends StatefulWidget {
  final bool useAsyncAwait; // true = async–await, false = callback chaining

  const AsyncLaundryPage({super.key, required this.useAsyncAwait});

  @override
  State<AsyncLaundryPage> createState() => _AsyncLaundryPageState();
}

class _AsyncLaundryPageState extends State<AsyncLaundryPage> {
  bool isLoading = false;
  String errorMessage = '';
  List<Map<String, dynamic>> produkList = [];

  // ======================================================
  // Versi async–await
  // ======================================================
  Future<void> _loadDataAsyncAwait() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    final stopwatch = Stopwatch()..start();
    try {
      final data = await HttpService.fetchProducts();
      setState(() {
        produkList = data.take(15).toList();
      });

      print('✅ [Async–Await] Waktu respon: ${stopwatch.elapsedMilliseconds} ms');
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
  // Versi callback chaining
  // ======================================================
  void _loadDataCallback() {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    final stopwatch = Stopwatch()..start();
    HttpService.fetchProducts().then((data) {
      setState(() {
        produkList = data.take(15).toList();
        isLoading = false;
      });

      print('✅ [Callback] Waktu respon: ${stopwatch.elapsedMilliseconds} ms');
    }).catchError((e) {
      setState(() {
        errorMessage = 'Terjadi error: $e';
        isLoading = false;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    if (widget.useAsyncAwait) {
      _loadDataAsyncAwait();
    } else {
      _loadDataCallback();
    }
  }

  @override
  Widget build(BuildContext context) {
    final mode = widget.useAsyncAwait ? 'Async–Await' : 'Callback Chaining';

    return Scaffold(
      appBar: AppBar(
        title: Text('Laundry $mode'),
        centerTitle: true,
        backgroundColor: Colors.lightBlue,
      ),
      body: Column(
        children: [
          _buildInfoBanner(mode),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : errorMessage.isNotEmpty
                    ? Center(child: Text(errorMessage))
                    : produkList.isEmpty
                        ? const Center(child: Text('Belum ada data produk.'))
                        : _buildGridProduk(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed:
            widget.useAsyncAwait ? _loadDataAsyncAwait : _loadDataCallback,
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
              'Menampilkan hasil dengan pendekatan $mode',
              style: const TextStyle(fontSize: 12, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridProduk() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: produkList.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 3 / 4,
      ),
      itemBuilder: (context, index) {
        final produk = produkList[index];
        final nama = produk['nama']?.toString() ?? 'Produk tanpa nama';
        final deskripsi = (produk['deskripsi'] != null &&
                produk['deskripsi'].toString().isNotEmpty)
            ? produk['deskripsi'].toString()
            : 'Tidak ada deskripsi untuk produk ini.';
        final harga = produk['harga'] ?? 0;
        final durasi = produk['durasi'] ?? '-';

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProductDetailPage(
                  productName: nama,
                  description: deskripsi,
                ),
              ),
            );
          },
          child: Card(
            color: Colors.lightBlue.shade100,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.local_laundry_service, size: 50),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    nama,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Rp$harga ($durasi)",
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.blueGrey,
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
