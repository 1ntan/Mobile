import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/http_service.dart';

class HttpLaundryController extends GetxController {
  var produkLaundry = <Map<String, dynamic>>[].obs;
  var filteredProduk = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;
  var downloadProgress = 0.0.obs;
  var searchQuery = ''.obs;

  final TextEditingController searchController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    // 🔹 Jalankan tes runtime otomatis pas menu HTTP dibuka
    HttpService.testHttpPerformance();

    // 🔹 Ambil data produk untuk ditampilkan di UI
    fetchProducts();

    // 🔹 Listener pencarian
    searchController.addListener(() {
      searchProduk(searchController.text);
    });
  }

  Future<void> fetchProducts() async {
    isLoading.value = true;
    final products = await HttpService.fetchProducts();
    produkLaundry.assignAll(products);
    filteredProduk.assignAll(products);
    isLoading.value = false;
  }

  void searchProduk(String query) {
    searchQuery.value = query;
    filteredProduk.assignAll(
      produkLaundry
          .where((p) => p['nama']
              .toString()
              .toLowerCase()
              .contains(query.toLowerCase()))
          .toList(),
    );
  }

  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
    filteredProduk.assignAll(produkLaundry);
  }
}
