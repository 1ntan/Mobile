import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/dio_service.dart';

class DioLaundryController extends GetxController {
  var produkLaundry = <String>[].obs;
  var filteredProduk = <String>[].obs;
  var isLoading = false.obs;
  var downloadProgress = 0.0.obs;
  var searchQuery = ''.obs;

  final TextEditingController searchController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    fetchProductsWithProgress();
    searchController.addListener(() {
      searchProduk(searchController.text);
    });
  }

  Future<void> fetchProductsWithProgress() async {
    isLoading.value = true;
    final products =
        await DioService.fetchProductsWithProgress((progress) {
      downloadProgress.value = progress;
    });
    produkLaundry.assignAll(products);
    filteredProduk.assignAll(products);
    isLoading.value = false;
    downloadProgress.value = 0.0;
  }

  void searchProduk(String query) {
    searchQuery.value = query;
    filteredProduk.assignAll(
      produkLaundry
          .where((p) => p.toLowerCase().contains(query.toLowerCase()))
          .toList(),
    );
  }

  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
    filteredProduk.assignAll(produkLaundry);
  }
}
