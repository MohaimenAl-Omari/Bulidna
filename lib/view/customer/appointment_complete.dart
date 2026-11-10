import 'package:buildna/components/custom_button.dart';
import 'package:buildna/controller/auth_controller.dart';
import 'package:buildna/controller/customer_controller.dart';
import 'package:buildna/view/customer/chat.dart';
import 'package:buildna/view/customer/describeIssue.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppointmentBookedPage extends StatelessWidget {
  AppointmentBookedPage({super.key});
  final AuthController authController = Get.find<AuthController>();
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Get.off(() => const DescribeIssuePage()),
          icon: const Icon(Icons.arrow_back_ios),
        ),
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: width * 0.06),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: height / 4),
            Image.asset(
              'assets/static/online-booking.png',
              height: height * 0.18,
            ),
            const SizedBox(height: 24),
            Text(
              'Appointment Booked'.tr,
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 23,
                shadows: [
                  Shadow(
                    offset: Offset(4, 8),
                    blurRadius: 12,
                    color: Colors.black26,
                  ),
                ],
              ),
            ),
            SizedBox(height: height * 0.065),
            CustomButton(
              onPressed: () async {
                await (authController.user as CustomerController).createChat(
                  (authController.user as CustomerController)
                      .pickedCraftsman['id']!,
                );
                Get.to(() => Chat());
              },
              text: 'Chat'.tr,
              height: height * 0.065,
            ),

            const Spacer(),
          ],
        ),
      ),
    );
  }
}
