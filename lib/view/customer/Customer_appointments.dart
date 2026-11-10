import 'package:buildna/components/custom_button.dart';
import 'package:buildna/components/custom_clickable_image.dart';
import 'package:buildna/controller/auth_controller.dart';
import 'package:buildna/controller/customer_controller.dart';
import 'package:buildna/view/customer/chat.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomerAppointments extends StatelessWidget {
  CustomerAppointments({super.key});

  final AuthController authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      authController.getAllAppointmentsForCustomer();
    });

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'My Appointments'.tr,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 22),
        ),
      ),
      body: Obx(() {
        if (authController.isLoadingAppointments.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return Column(
          children: [
            SizedBox(height: height / 40),
            Expanded(
              child: Obx(
                () => ListView.builder(
                  padding: EdgeInsets.all(width / 30),
                  itemCount: authController.craftsmanAppointments.length,
                  itemBuilder: (context, index) {
                    final item = authController.craftsmanAppointments[index];
                    return Container(
                      margin: EdgeInsets.only(bottom: height / 40),
                      padding: EdgeInsets.all(width / 30),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 248, 245, 248),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          ClickableImage(
                            imagePath: item['craftsman_image_url'] ?? '',
                            height: height / 5.5,
                            width: width / 3.5,
                            onTap: () {},
                          ),
                          SizedBox(width: width / 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['craftsman_username'] ?? 'Unknown',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 18,
                                    color: Colors.black,
                                  ),
                                ),
                                SizedBox(height: height / 100),
                                Text(
                                  'Phone: ${item['craftsman_phone'] ?? 'N/A'}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                                SizedBox(height: height / 100),
                                Text(
                                  'City: ${item['craftsman_city'] ?? 'N/A'}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                                SizedBox(height: height / 60),
                                CustomButton(
                                  onPressed: () async {
                                    await (authController.user
                                            as CustomerController)
                                        .getOneCraftsman(item['craftsman_id']);
                                    Get.to(() => Chat());
                                  },
                                  text: 'Chat'.tr,
                                  height: height / 30,
                                  fontSize: 17,
                                  borderRadius: 8,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
