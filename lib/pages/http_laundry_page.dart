import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/http_service.dart';
import 'product_detail_page.dart';

class HttpLaundryPage extends StatefulWidget {
  const HttpLaundryPage({super.key});

  @override
  State<HttpLaundryPage> createState() => _HttpLaundryPageState();
}

class _HttpLaundryPageState extends State<HttpLaundryPage> {
  List<Map<String, dynamic>> apiProducts = [];
  List<Map<String, dynamic>> filteredProducts = [];
  bool isLoading = true;
  int? _tappedIndex;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _runHttpPerformanceAndLoadProducts(); // otomatis tes runtime & load data

    _searchController.addListener(() {
      final query = _searchController.text.toLowerCase();
      setState(() {
        filteredProducts = apiProducts
            .where((p) =>
                p['nama'].toString().toLowerCase().contains(query))
            .toList();
      });
    });
  }

  Future<void> _runHttpPerformanceAndLoadProducts() async {
    await HttpService.testHttpPerformance(); // tampil runtime di terminal
    await loadProducts(); // lanjut load data produk
  }

  Future<void> loadProducts() async {
    setState(() => isLoading = true);
    final data = await HttpService.fetchProducts();
    setState(() {
      apiProducts = data;
      filteredProducts = data;
      isLoading = false;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int crossAxisCount = (MediaQuery.of(context).size.width ~/ 180).clamp(2, 4);

    // Warna ikon sesuai tema
    final iconColor = Get.isDarkMode ? Colors.yellow : Colors.black87;
    final appBarColor = Get.isDarkMode ? Colors.grey[900] : Colors.lightBlue;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Produk HTTP'),
        centerTitle: true,
        backgroundColor: appBarColor,
        actions: [
          // 🔹 Ikon pertama: Tes runtime manual
          IconButton(
            icon: Icon(Icons.timer, color: Get.isDarkMode ? Colors.yellow : Colors.white),
            tooltip: 'Tes Runtime HTTP',
            onPressed: () async {
              await HttpService.testHttpPerformance();
            },
          ),
          // 🔹 Ikon kedua: Ganti tema
          IconButton(
            icon: Icon(
              Theme.of(context).brightness == Brightness.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            onPressed: () {
              final isDark = Theme.of(context).brightness == Brightness.dark;
              Get.changeThemeMode(isDark ? ThemeMode.light : ThemeMode.dark);
            },
          ),

        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari produk...',
                prefixIcon: Icon(Icons.search, color: iconColor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.lightBlue),
                  )
                : filteredProducts.isEmpty
                    ? const Center(child: Text('Belum ada data produk.'))
                    : GridView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredProducts.length,
                        gridDelegate:
                            SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 3 / 4,
                        ),
                        itemBuilder: (context, index) {
                          final product = filteredProducts[index];
                          final bool isTapped = _tappedIndex == index;
                          return GestureDetector(
                            onTapDown: (_) =>
                                setState(() => _tappedIndex = index),
                            onTapUp: (_) {
                              Future.delayed(
                                const Duration(milliseconds: 150),
                                () {
                                  setState(() => _tappedIndex = null);
                                },
                              );
                              Navigator.push(
                                context,
                                PageRouteBuilder(
                                  transitionDuration:
                                      const Duration(milliseconds: 450),
                                  pageBuilder: (context, animation,
                                          secondaryAnimation) =>
                                      ProductDetailPage(
                                          productName:
                                              product['nama'] ?? 'Tanpa Nama'),
                                  transitionsBuilder: (context, animation,
                                      secondaryAnimation, child) {
                                    final fade = CurvedAnimation(
                                      parent: animation,
                                      curve: Curves.easeInOut,
                                    );
                                    return FadeTransition(
                                        opacity: fade, child: child);
                                  },
                                ),
                              );
                            },
                            onTapCancel: () => setState(() => _tappedIndex = null),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                              transform: Matrix4.identity()
                                ..scale(isTapped ? 1.05 : 1.0),
                              decoration: BoxDecoration(
                                color: isTapped
                                    ? (Get.isDarkMode ? Colors.blueGrey.shade700 : Colors.lightBlue.shade300)
                                    : (Get.isDarkMode ? Colors.grey.shade800 : Colors.lightBlue.shade100),
                                borderRadius: BorderRadius.circular(
                                    isTapped ? 24 : 12),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Hero(
                                    tag: product['id'].toString(),
                                    child: Icon(
                                      Icons.local_laundry_service,
                                      size: isTapped ? 60 : 50,
                                      color: isTapped
                                          ? Colors.white
                                          : Colors.blueGrey.shade700,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    product['nama'] ?? 'Tanpa Nama',
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: isTapped ? 18 : 16,
                                      color: isTapped
                                          ? Colors.white
                                          : Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    "Rp${product['harga'] ?? 0}",
                                    style: TextStyle(
                                      color: isTapped ? Colors.white70 : Colors.blue,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "${product['durasi'] ?? '-'}",
                                    style: TextStyle(
                                      color: isTapped ? Colors.white70 : Colors.black54,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
