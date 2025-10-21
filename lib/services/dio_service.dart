import 'package:dio/dio.dart';

class DioService {
  static Future<List<String>> fetchProductsWithProgress(
      Function(double) onProgress) async {
    final dio = Dio();
    try {
      final response = await dio.get(
        'https://dummyjson.com/products', //link api
        onReceiveProgress: (received, total) {
          if (total != -1) {
            onProgress(received / total);
          }
        },
      );

      final List products = response.data['products'];
      return products.map<String>((p) => p['title'].toString()).toList();
    } catch (e) {
      print('❌ Dio Error: $e');
      return [];
    }
  }

  static Future<void> testDioPerformance() async {
    final dio = Dio();
    final stopwatch = Stopwatch()..start();
    print('🟣 [DIO] Starting request...');
    try {
      final response = await dio.get('https://dummyjson.com/products');
      stopwatch.stop();
      print('==============================');
      print('🌐 DIO TEST RESULT');
      print('Status Code : ${response.statusCode}');
      print('Response Time: ${stopwatch.elapsedMilliseconds} ms');
      print('Data Length  : ${response.data['products']?.length}');
      print('==============================');
    } catch (e) {
      stopwatch.stop();
      print('❌ DIO Error: $e');
    }
  }
}
