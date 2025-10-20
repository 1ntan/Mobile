import 'package:dio/dio.dart';

class DioService {
  static Future<void> testDioPerformance() async {
    final stopwatch = Stopwatch()..start();
    print('🟣 [DIO] Memulai request...');

    try {
      final dio = Dio(
        BaseOptions(
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      // 🔹 Ganti API ke yang bebas tanpa API key
      final response = await dio.get('https://jsonplaceholder.typicode.com/users');

      stopwatch.stop();

      print('==============================');
      print('🌐 DIO TEST RESULT');
      print('Status Code : ${response.statusCode}');
      print('Response Time: ${stopwatch.elapsedMilliseconds} ms');
      print('Data Length : ${(response.data as List).length}');
      print('==============================');
    } catch (e) {
      stopwatch.stop();
      print('❌ DIO Error: $e');
    }
  }
}
