import 'dart:convert';
import 'package:http/http.dart' as http;

class HttpService {
  /// Ambil daftar layanan laundry (data map, bukan string)
  static Future<List<Map<String, dynamic>>> fetchProducts() async {
    try {
      final response = await http.get(
        Uri.parse('https://68fc553a96f6ff19b9f4d297.mockapi.io/api/v1/layanan'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        // Mapping ke Map<String, dynamic>
        return data.map<Map<String, dynamic>>((p) {
          return {
            'id': p['id'],
            'nama': p['nama'] ?? 'Tanpa Nama',
            'harga': p['harga'] ?? 0,
            'durasi': p['durasi'] ?? '-',
          };
        }).toList();
      } else {
        return [];
      }
    } catch (e) {
      print('❌ HTTP Error: $e');
      return [];
    }
  }

  /// Tes performa request HTTP
  static Future<void> testHttpPerformance() async {
    final stopwatch = Stopwatch()..start();
    print('🟣 [HTTP] Memulai request...');
    try {
      final response = await http.get(
        Uri.parse('https://68fc553a96f6ff19b9f4d297.mockapi.io/api/v1/layanan'),
      );
      stopwatch.stop();

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print('==============================');
        print('🌐 HTTP TEST RESULT');
        print('Status Code : ${response.statusCode}');
        print('Response Time: ${stopwatch.elapsedMilliseconds} ms');
        print('Data Length  : ${data.length}');
        print('==============================');
      } else {
        print('⚠️ Gagal. Status code: ${response.statusCode}');
      }
    } catch (e) {
      stopwatch.stop();
      print('❌ HTTP Error: $e');
    }
  }
}
