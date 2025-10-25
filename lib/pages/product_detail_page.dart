import 'package:flutter/material.dart';

class ProductDetailPage extends StatelessWidget {
  final String productName;
  const ProductDetailPage({super.key, required this.productName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(productName),
        backgroundColor: Colors.lightBlue,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Hero(
              tag: productName,
              child: Icon(
                Icons.local_laundry_service,
                size: 150,
                color: Colors.blueAccent,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Detail untuk $productName',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}