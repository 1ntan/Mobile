import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/theme_controller.dart';
import 'http_laundry_page.dart';
import 'dio_laundry_page.dart';
import 'async_laundry_page.dart'; 

class MainMenuPage extends StatefulWidget {
  const MainMenuPage({super.key});

  @override
  State<MainMenuPage> createState() => _MainMenuPageState();
}

class _MainMenuPageState extends State<MainMenuPage> {
  final ThemeController themeController = Get.find();
  bool showAsyncOptions = false; // 👈 untuk menampilkan tombol turunan Async

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.find();
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Gangnam Laundry'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Obx(() => Icon(
                  themeController.themeMode.value == ThemeMode.dark
                      ? Icons.light_mode
                      : Icons.dark_mode,
                )),
            onPressed: () => themeController.toggleTheme(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height -
                kToolbarHeight -
                MediaQuery.of(context).padding.top,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.local_laundry_service,
                color: Theme.of(context).colorScheme.primary,
                size: 120,
              ),
              const SizedBox(height: 12),
              Text(
                'Gangnam Laundry',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 60),

              // Tombol menuju halaman HTTP
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const HttpLaundryPage()),
                    );
                  },
                  icon: const Icon(Icons.http, color: Colors.white),
                  label: const Text(
                    'Laundry HTTP',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Tombol menuju halaman DIO
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const DioLaundryPage()),
                    );
                  },
                  icon: const Icon(Icons.cloud_download, color: Colors.white),
                  label: const Text(
                    'Laundry DIO',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // ======================
              // Tombol: Async (baru)
              // ======================
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.deepPurple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      showAsyncOptions = !showAsyncOptions;
                    });
                  },
                  icon: const Icon(Icons.bolt, color: Colors.white),
                  label: const Text('Async',
                      style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ),

              // ======================
              // Tombol turunan Async
              // ======================
              if (showAsyncOptions) ...[
                const SizedBox(height: 12),
                // Sync–Await
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purpleAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const AsyncLaundryPage(useAsyncAwait: true),
                      ),
                    );
                  },
                  child: const Text('Sync–Await'),
                ),
                const SizedBox(height: 8),

                // Callback Chaining
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purpleAccent.shade100,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const AsyncLaundryPage(useAsyncAwait: false),
                      ),
                    );
                  },
                  child: const Text('Callback Chaining'),
                ),
              ],

              const SizedBox(height: 24),
              Text(
                'Hasil pengukuran response time akan muncul di terminal (console).',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
