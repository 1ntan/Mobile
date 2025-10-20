import 'package:flutter/material.dart';
import '../services/http_service.dart';
import 'product_detail_page.dart';

class HttpLaundryPage extends StatefulWidget {
  const HttpLaundryPage({super.key});

  @override
  State<HttpLaundryPage> createState() => _HttpLaundryPageState();
}

class _HttpLaundryPageState extends State<HttpLaundryPage> {
  final List<String> produkLaundry = const [
    'Cuci Kering',
    'Cuci Setrika',
    'Setrika Saja',
    'Cuci Sepatu',
    'Cuci Karpet',
    'Dry Cleaning',
    'Laundry Express',
    'Bed Cover',
    'Jas & Gaun',
    'Boneka',
    'Tas & Helm',
    'Sprei & Selimut',
  ];

  List<String> filteredProduk = [];
  int? _tappedIndex;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredProduk = produkLaundry;
    // Jalankan pengujian HTTP tiap kali halaman dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      HttpService.testHttpPerformance();
    });

    _searchController.addListener(() {
      final query = _searchController.text.toLowerCase();
      setState(() {
        filteredProduk = produkLaundry
            .where((p) => p.toLowerCase().contains(query))
            .toList();
      });
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Laundry HTTP'),
        centerTitle: true,
        backgroundColor: Colors.lightBlue,
      ),
      body: Column(
        children: [
          // Header + Test Button
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Halaman HTTP — hasil test ditampilkan di terminal',
                    style: TextStyle(fontSize: 14),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => HttpService.testHttpPerformance(),
                  child: const Text('Test Lagi'),
                ),
              ],
            ),
          ),

          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari produk laundry...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          // Grid Produk
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredProduk.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 3 / 4,
              ),
              itemBuilder: (context, index) {
                final product = filteredProduk[index];
                final bool isTapped = _tappedIndex == index;

                return GestureDetector(
                  onTapDown: (_) => setState(() => _tappedIndex = index),
                  onTapUp: (_) {
                    Future.delayed(const Duration(milliseconds: 150), () {
                      setState(() => _tappedIndex = null);
                    });
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        transitionDuration: const Duration(milliseconds: 450),
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            ProductDetailPage(productName: product),
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
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    transform: Matrix4.identity()..scale(isTapped ? 1.05 : 1.0),
                    decoration: BoxDecoration(
                      color: isTapped
                          ? Colors.lightBlue.shade300
                          : Colors.lightBlue.shade100,
                      borderRadius: BorderRadius.circular(isTapped ? 24 : 12),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Hero(
                          tag: product,
                          child: Icon(
                            Icons.local_laundry_service,
                            size: isTapped ? 60 : 50,
                            color:
                                isTapped ? Colors.white : Colors.blueGrey.shade700,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          product,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: isTapped ? 18 : 16,
                            color: isTapped ? Colors.white : Colors.black87,
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
