import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/dio_service.dart';
import '../controllers/dio_laundry_controller.dart';
import 'product_detail_page.dart';

class DioLaundryPage extends StatelessWidget {
  const DioLaundryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DioLaundryController());
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Laundry DIO'),
        centerTitle: true,
        backgroundColor: Colors.lightBlue,
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: () {
              Get.changeThemeMode(isDark ? ThemeMode.light : ThemeMode.dark);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildInfoBanner(context),

          // 🔹 Progress bar untuk pitching
          _buildProgressIndicator(controller),

          // 🔹 Tombol pitching (fetch with progress)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ElevatedButton.icon(
              onPressed: controller.fetchProductsWithProgress,
              icon: const Icon(Icons.cloud_download),
              label: const Text('Fetch with Pitching'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          _buildSearchBar(controller),
          Expanded(child: _buildProductGrid(controller)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: DioService.testDioPerformance,
        icon: const Icon(Icons.speed),
        label: const Text('Test Speed'),
      ),
    );
  }

  Widget _buildInfoBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      color: Colors.blue.withOpacity(0.1),
      child: Row(
        children: const [
          Icon(Icons.info_outline, size: 18, color: Colors.blue),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Menampilkan progress pitching (download tracking) menggunakan Dio',
              style: TextStyle(fontSize: 12, color: Colors.black87),
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

  Widget _buildSearchBar(DioLaundryController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: TextField(
        controller: controller.searchController,
        onChanged: controller.searchProduk,
        decoration: InputDecoration(
          hintText: 'Cari produk laundry...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: Obx(() {
            if (controller.searchQuery.value.isNotEmpty) {
              return IconButton(
                icon: const Icon(Icons.clear),
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

  Widget _buildProductGrid(DioLaundryController controller) {
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
                  color: Colors.lightBlue.shade100,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.local_laundry_service, size: 50),
                      const SizedBox(height: 10),
                      Text(product,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
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
