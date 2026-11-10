import 'package:buildna/components/custom_button.dart';
import 'package:buildna/components/custom_clickable_image.dart';
import 'package:buildna/controller/auth_controller.dart';
import 'package:buildna/controller/customer_controller.dart';
import 'package:buildna/view/customer/describeIssue.dart';
import 'package:buildna/view/customer/show_reviews.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
// Keep your imports...

class CraftsmanDetails extends StatelessWidget {
  CraftsmanDetails({super.key});
  final AuthController authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    final customer = authController.user as CustomerController;
    Future.microtask(
      () => customer.checkIfFavorite(customer.pickedCraftsman['id']!),
    );

    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          'Craftsman profile'.tr,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 22,
            color: Colors.black,
          ),
        ),
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
        ),
      ),
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: width * 0.05,
          vertical: height * 0.02,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🧑‍🔧 Craftsman Info Card
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: EdgeInsets.all(width * 0.04),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: ClickableImage(
                        imagePath: customer.pickedCraftsman['ImageURL'] ?? '',
                        height: height * 0.15,
                        width: width * 0.26,
                        onTap: () {},
                      ),
                    ),
                    SizedBox(width: width * 0.04),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            customer.pickedCraftsman['username']?.capitalize ??
                                'N/A',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: width * 0.05,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            customer.pickedCraftsman['Speciality'] ?? 'N/A',
                            style: TextStyle(
                              fontSize: width * 0.035,
                              color: Colors.grey[700],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              _buildIconButton(
                                icon: Icons.call_outlined,
                                color: Colors.green,
                                onTap:
                                    () => _showCallConfirmation(
                                      context,
                                      customer,
                                    ),
                              ),
                              Obx(() {
                                final isFav =
                                    customer.isCraftsmanFavorite.value;
                                return _buildIconButton(
                                  icon:
                                      isFav
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                  color: Colors.red,
                                  onTap:
                                      () => customer.toggleFavoriteCraftsman(
                                        customer.pickedCraftsman['id']!,
                                      ),
                                );
                              }),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: height * 0.025),

            // 📋 Description Section
            _cardSection(
              title: 'Details'.tr,
              content:
                  customer.pickedCraftsman['Description'] ??
                  'No description available.',
              width: width,
            ),

            SizedBox(height: height * 0.025),

            // ⭐ Review Button
            Center(
              child: CustomButton(
                onPressed: () async {
                  await customer.getCraftsmanReviews();
                  Get.to(() => ShowReviews());
                },
                text: 'Show Reviews'.tr,
                height: height * 0.05,
              ),
            ),

            SizedBox(height: height * 0.035),

            // 🕒 Working Hours
            _workingHoursCard(customer, width, height),

            SizedBox(height: height * 0.04),
          ],
        ),
      ),

      // 📅 Bottom Booking Button
      bottomNavigationBar: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: width * 0.1,
          vertical: height * 0.02,
        ),
        child: CustomButton(
          onPressed: () async {
            await customer.getOneCraftsman(customer.pickedCraftsman['id']!);
            if (customer.pickedCraftsmanWorkDays.isEmpty) {
              Get.snackbar(
                'Unavailable'.tr,
                'This craftsman finished this week reservation 😊'.tr,
                duration: const Duration(seconds: 5),
                colorText: Colors.black,
                snackPosition: SnackPosition.TOP,
              );
            } else {
              Get.to(() => const DescribeIssuePage());
            }
          },
          text: 'Book an Appointment'.tr,
          height: height * 0.065,
        ),
      ),
    );
  }

  // 📱 Custom Call Confirmation Dialog
  void _showCallConfirmation(
    BuildContext context,
    CustomerController customer,
  ) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 10,
            backgroundColor: Colors.white,
            title: const Row(
              children: [
                Icon(Icons.call, color: Colors.green),
                SizedBox(width: 8),
                Text(
                  'Confirm Call',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            content: const Text(
              'You’re about to leave the app!\nAnything that happens outside the chat is not covered by us.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(foregroundColor: Colors.grey),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  authController.launchPhoneDialer(
                    customer.pickedCraftsman['phonenumber']!,
                  );
                },
                style: TextButton.styleFrom(foregroundColor: Colors.green),
                child: const Text('Call'),
              ),
            ],
          ),
    );
  }

  // 💬 Icon Buttons (Call/Favorite)
  Widget _buildIconButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return IconButton(
      icon: Icon(icon, color: color, size: 28),
      onPressed: onTap,
    );
  }

  // 📄 Generic Card with Section
  Widget _cardSection({
    required String title,
    required String content,
    required double width,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(width * 0.045),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: width * 0.045,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              content,
              style: TextStyle(
                fontSize: width * 0.035,
                height: 1.4,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🕒 Working Hours Section
  Widget _workingHoursCard(
    CustomerController customer,
    double width,
    double height,
  ) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(width * 0.045),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Working Days & Hours'.tr,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: width * 0.045,
              ),
            ),
            SizedBox(height: height * 0.015),
            Text(
              '${'Days'.tr}: ${customer.craftsmanWorkDays}',
              style: TextStyle(fontSize: width * 0.035),
            ),
            SizedBox(height: height * 0.01),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${'From'.tr}: \u200E${customer.pickedCraftsman['from'] ?? 'N/A'}',
                    style: TextStyle(fontSize: width * 0.035),
                  ),
                ),
                Expanded(
                  child: Text(
                    '${'To'.tr}: \u200E${customer.pickedCraftsman['to'] ?? 'N/A'}',
                    style: TextStyle(fontSize: width * 0.035),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
