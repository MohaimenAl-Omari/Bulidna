import 'package:buildna/components/custom_clickable_image.dart';
import 'package:buildna/controller/admin_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CraftsmanDetailsPage extends StatelessWidget {
  final String craftsmanId;
  CraftsmanDetailsPage({super.key, required this.craftsmanId});

  final AdminController adminController = Get.find<AdminController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Craftsman Details')),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: adminController.getCraftsmanFullData(craftsmanId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('Craftsman not found'));
          }

          final data = snapshot.data!;
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ClickableImage(
                    imagePath: data['ImageURL'] ?? '',
                    width: 100,
                    height: 100,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    data['username'] ?? '',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(data['email'] ?? ''),
                  Text(data['phonenumber'] ?? ''),
                  Text("City: ${data['city'] ?? ''}"),
                  const Divider(height: 30),
                  Text(
                    data['Description'] ?? 'No description available',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 100),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ClickableImage(
                        imagePath: data['CardFront'] ?? '',
                        width: 150,
                        height: 150,
                      ),
                      ClickableImage(
                        imagePath: data['CardBack'] ?? '',
                        width: 150,
                        height: 150,
                      ),
                    ],
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            await adminController.updateCraftsmanStatus(
                              craftsmanId,
                              1,
                            );
                            Get.back();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                          child: const Text('Accept'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            await adminController.updateCraftsmanStatus(
                              craftsmanId,
                              0,
                            );
                            Get.back();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          child: const Text('Reject'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
