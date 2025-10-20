import 'package:http/http.dart' as http;

class HttpService {
  static Future<void> testHttpPerformance() async {
    final stopwatch = Stopwatch()..start();
    print('🔵 [HTTP] Memulai request...');

    try {
      final response =
          await http.get(Uri.parse('https://reqres.in/api/users?page=1'));
      stopwatch.stop();

      print('==============================');
      print('📡 HTTP TEST RESULT');
      print('Status Code : ${response.statusCode}');
      print('Response Time: ${stopwatch.elapsedMilliseconds} ms');
      print('==============================');
    } catch (e) {
      stopwatch.stop();
      print('❌ HTTP Error: $e');
    }
  }
}
