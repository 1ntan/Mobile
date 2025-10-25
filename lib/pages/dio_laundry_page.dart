import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/dio_service.dart';
import '../controllers/dio_laundry_controller.dart';
import 'product_detail_page.dart';

class DioLaundryPage extends StatefulWidget {
  const DioLaundryPage({super.key});

  @override
  State<DioLaundryPage> createState() => _DioLaundryPageState();
}

class _DioLaundryPageState extends State<DioLaundryPage> {
  late DioLaundryController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(DioLaundryController());
    // Tes runtime otomatis saat page dibuka
    DioService.testDioPerformance();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconColor = isDark ? Colors.yellow : Colors.white;
    final appBarColor = isDark ? Colors.grey[900] : Colors.lightBlue;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Laundry DIO'),
        centerTitle: true,
        backgroundColor: appBarColor,
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode, color: iconColor),
            onPressed: () {
              Get.changeThemeMode(isDark ? ThemeMode.light : ThemeMode.dark);
              setState(() {}); // rebuild supaya ikon berubah
            },
          ),
          IconButton(
            icon: Icon(Icons.speed, color: iconColor),
            tooltip: 'Tes Speed',
            onPressed: DioService.testDioPerformance,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildInfoBanner(context, isDark),

          // 🔹 Progress bar untuk pitching
          _buildProgressIndicator(controller),

          // 🔹 Tombol pitching (fetch with progress)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ElevatedButton.icon(
              onPressed: controller.fetchProductsWithProgress,
              icon: Icon(Icons.cloud_download, color: iconColor),
              label: Text('Fetch with Pitching', style: TextStyle(color: iconColor)),
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? Colors.black87 : Colors.lightBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          _buildSearchBar(controller, iconColor),
          Expanded(child: _buildProductGrid(controller, isDark)),
        ],
      ),
    );
  }

  Widget _buildInfoBanner(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      color: isDark ? Colors.grey.shade800 : Colors.blue.withOpacity(0.1),
      child: Row(
        children: [
          Icon(Icons.info_outline, size: 18, color: isDark ? Colors.yellow : Colors.blue),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Menampilkan progress pitching (download tracking) menggunakan Dio',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(DioLaundryController controller) {
    return Obx(() {
      final progress = controller.downloadProgress.value;

      if (progress > 0 && progress < 1) {
        return Column(
          children: [
            LinearProgressIndicator(value: progress),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Downloading: ${(progress * 100).toStringAsFixed(0)}%',
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ],
        );
      }
      return const SizedBox.shrink();
    });
  }

  Widget _buildSearchBar(DioLaundryController controller, Color iconColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: TextField(
        controller: controller.searchController,
        onChanged: controller.searchProduk,
        decoration: InputDecoration(
          hintText: 'Cari produk laundry...',
          prefixIcon: Icon(Icons.search, color: iconColor),
          suffixIcon: Obx(() {
            if (controller.searchQuery.value.isNotEmpty) {
              return IconButton(
                icon: Icon(Icons.clear, color: iconColor),
                onPressed: controller.clearSearch,
              );
            }
            return const SizedBox.shrink();
          }),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildProductGrid(DioLaundryController controller, bool isDark) {
    return Obx(() {
      if (controller.isLoading.value && controller.filteredProduk.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.filteredProduk.isEmpty) {
        return const Center(child: Text('Tidak ada produk ditemukan'));
      }

      return LayoutBuilder(
        builder: (context, constraints) {
          final crossAxisCount = (constraints.maxWidth ~/ 180).clamp(2, 4);

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.filteredProduk.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 3 / 4,
            ),
            itemBuilder: (context, index) {
              final product = controller.filteredProduk[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      transitionDuration: const Duration(milliseconds: 450),
                      pageBuilder: (_, __, ___) =>
                          ProductDetailPage(productName: product),
                      transitionsBuilder:
                          (_, animation, __, child) => FadeTransition(
                        opacity:
                            CurvedAnimation(parent: animation, curve: Curves.easeInOut),
                        child: child,
                      ),
                    ),
                  );
                },
                child: Card(
                  color: isDark
                      ? Colors.grey.shade800
                      : Colors.lightBlue.shade100,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.local_laundry_service,
                          size: 50, color: isDark ? Colors.yellow : Colors.blueGrey.shade700),
                      const SizedBox(height: 10),
                      Text(product,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: isDark ? Colors.yellow : Colors.black87)),
                    ],
                  ),
                ),
              );
            },
          );
        },
      );
    });
  }
}
