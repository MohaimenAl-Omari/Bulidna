import 'package:buildna/components/custom_button.dart';
import 'package:buildna/components/custom_clickable_image.dart';
import 'package:buildna/controller/auth_controller.dart';
import 'package:buildna/controller/craftsman_controller.dart';
import 'package:buildna/view/craftsman/chat.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ViewAppointment extends StatelessWidget {
  ViewAppointment({super.key, required this.appointment});
  final Map<String, dynamic> appointment;
  final AuthController authController = Get.find<AuthController>();
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          'Appointments'.tr,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        actions: [
          appointment['completed'] == false
              ? Container(
                padding: EdgeInsets.only(right: width / 10), // optional spacing
                child: CustomButton(
                  onPressed: () async {
                    await (authController.user as CraftsmanController)
                        .markAppointmentAsCompleted(
                          appointment['appointment_id'],
                        );
                    Get.back();
                  },
                  text: 'Mark as completed'.tr,
                  height: height / 30,
                  fontSize: 10,
                ),
              )
              : Container(),
        ],
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back_ios),
        ),
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClickableImage(
              height: height / 1.7,
              width: width,
              imagePath: appointment['image_url'],
            ),
            SizedBox(height: height / 60),
            Container(
              width: width,
              margin: EdgeInsets.symmetric(horizontal: width / 30),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    // ignore: deprecated_member_use
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.all(width / 30),
                    child: Text(
                      'Description'.tr,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Divider(height: 1, color: Colors.grey.shade300),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: height / 8,
                      maxHeight: height / 3.5,
                    ),
                    child: Scrollbar(
                      thumbVisibility: true,
                      thickness: 4,
                      radius: const Radius.circular(10),
                      child: SingleChildScrollView(
                        padding: EdgeInsets.all(width / 30),
                        child: Text(
                          appointment['description']?.isNotEmpty == true
                              ? appointment['description']
                              : 'No description available',
                          style: const TextStyle(
                            fontSize: 16,
                            height: 1.5,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: height / 30), // ✅ Add some spacing before button
            CustomButton(
              onPressed: () async {
                await (authController.user as CraftsmanController)
                    .getOneCustomer(appointment['customer_id']);
                Get.to(
                  () => Chat(
                    customer:
                        (authController.user as CraftsmanController)
                            .pickedCustomer,
                  ),
                );
              },
              text: 'Chat'.tr,
              height: height / 20,
              width: width / 1.5,
            ),
            SizedBox(
              height: height / 30,
            ), // ✅ Add bottom padding to prevent clipping
          ],
        ),
      ),
    );
  }
}
