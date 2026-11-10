import 'package:buildna/components/custom_clickable_image.dart';
import 'package:buildna/controller/auth_controller.dart';
import 'package:buildna/view/auth/login.dart';
import 'package:buildna/view/craftsman/Craftsman_Profile_Page.dart';
import 'package:buildna/view/craftsman/customer_list.dart';
import 'package:buildna/view/craftsman/schedule_page.dart';
import 'package:buildna/view/craftsman/view_appointment.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../helpers/otp_session.dart';

class CraftsmanHome extends StatelessWidget {
  const CraftsmanHome({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();
    final PageController pageController = PageController();

    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: width * 0.05),
      child: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: height * 0.05),
            Row(
              children: [
                ClipOval(
                  child: ClickableImage(
                    imagePath: authController.user.imageURL.value,
                    height: height * 0.08,
                    width: height * 0.08,
                    onTap: () {
                      Get.to(() => CraftsmanProfilePage());
                    },
                  ),
                ),
                SizedBox(width: width * 0.04),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        authController.user.username.value,
                        style: TextStyle(
                          fontSize: width * 0.05,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'greetings'.tr,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    OtpSession.clear();
                    FirebaseAuth.instance.signOut();
                    Get.offAll(() => LoginPage());
                  },
                  icon: const Icon(Icons.login_outlined),
                ),
              ],
            ),
            SizedBox(height: height * 0.03),
            SizedBox(
              height: height * 0.23,
              child: PageView(
                controller: pageController,
                children: List.generate(
                  4,
                  (index) => _showPageView(height, width),
                ),
              ),
            ),
            SizedBox(height: height * 0.015),
            SmoothPageIndicator(
              controller: pageController,
              count: 4,
              effect: const WormEffect(
                dotHeight: 10,
                dotWidth: 10,
                activeDotColor: Colors.black,
              ),
            ),
            SizedBox(height: height * 0.025),
            Container(
              padding: EdgeInsets.all(width * 0.05),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    'payment'.tr,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: height * 0.01),
                  Text(
                    '${'soon'.tr}🔒',
                    style: const TextStyle(
                      color: Colors.yellow,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: height * 0.01),
                  Container(
                    width: double.infinity,
                    height: height * 0.05,
                    decoration: BoxDecoration(
                      color: Colors.white10,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'click here'.tr,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: height * 0.025),
            Container(
              width: double.infinity,
              height: height * 0.06,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: GestureDetector(
                onTap: () => Get.to(() => const SchedulePage()),
                child: Text(
                  'Make my schedule'.tr,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            SizedBox(height: height * 0.03),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Appointments'.tr,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    await authController.getIncompleteAppointments();
                    Get.to(() => const CustomerList());
                  },
                  child: Text(
                    'See All'.tr,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: height * 0.02),
            // Add your dynamic appointment widgets here
            Obx(() {
              final appointments = authController.lastTwoAppointments;
              if (appointments.isEmpty) {
                return Text(
                  'No appointments available'.tr,
                  style: const TextStyle(color: Colors.grey),
                );
              }
              return SizedBox(
                height: height * 0.22,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: appointments.length,
                  itemBuilder: (context, index) {
                    final item = appointments[index];
                    return Container(
                      margin: EdgeInsets.only(right: width * 0.04),
                      padding: EdgeInsets.all(width * 0.02),
                      width: width * 0.4,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          if (item['ImageURL'] != '')
                            ClickableImage(
                              imagePath: item['ImageURL'],
                              height: height * 0.1,
                              width: double.infinity,
                              onTap: () async {
                                Get.to(
                                  () => ViewAppointment(appointment: item),
                                );
                              },
                            ),
                          SizedBox(height: height * 0.01),
                          Text(
                            item['username'],
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: height * 0.005),
                        ],
                      ),
                    );
                  },
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _showPageView(double height, double width) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: width * 0.04),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text.rich(
                  TextSpan(
                    text: 'BUILD',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 22,
                    ),
                    children: [
                      TextSpan(
                        text: 'NA',
                        style: TextStyle(
                          color: Colors.yellow,
                          fontWeight: FontWeight.w600,
                          fontSize: 22,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Craftsmen bring a high level of skill, patience, and attention to detail to their craft',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
          SizedBox(width: width * 0.02),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ClickableImage(
                imagePath: 'assets/static/craftsman.png',
                height: height * 0.14,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
