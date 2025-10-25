import 'package:dio/dio.dart';

class DioService {
  /// Ambil data layanan dari MockAPI
  static Future<List<String>> fetchProductsWithProgress(
      Function(double) onProgress) async {
    final dio = Dio();

    try {
      final response = await dio.get(
        'https://68fc553a96f6ff19b9f4d297.mockapi.io/api/v1/layanan',
        onReceiveProgress: (received, total) {
          if (total != -1) {
            onProgress(received / total);
          }
        },
      );

      // ✅ Data dari MockAPI langsung berupa list
      final List<dynamic> products = response.data;

      // ✅ Pastikan field yang diambil sesuai API
      return products.map<String>((p) {
        final nama = p['nama'] ?? 'Tanpa Nama';
        final harga = p['harga'] ?? '-';
        final durasi = p['durasi'] ?? '-';
        return '$nama — Rp$harga ($durasi)';
      }).toList();
    } catch (e) {
      print('❌ Dio Error: $e');
      return [];
    }
  }

  /// Tes performa saat request dijalankan
  static Future<void> testDioPerformance() async {
    final dio = Dio();
    final stopwatch = Stopwatch()..start();
    print('🟣 [DIO] Memulai request...');

    try {
      final response = await dio.get(
        'https://68fc553a96f6ff19b9f4d297.mockapi.io/api/v1/layanan',
      );
      stopwatch.stop();

      final List<dynamic> data = response.data;

      print('==============================');
      print('🌐 DIO TEST RESULT');
      print('Status Code : ${response.statusCode}');
      print('Response Time: ${stopwatch.elapsedMilliseconds} ms');
      print('Data Length  : ${data.length}');
      print('==============================');
    } catch (e) {
      stopwatch.stop();
      print('❌ DIO Error: $e');
    }
  }
}
