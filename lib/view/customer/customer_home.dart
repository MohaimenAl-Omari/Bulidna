import 'package:buildna/components/custom_clickable_image.dart';
import 'package:buildna/controller/auth_controller.dart';
import 'package:buildna/controller/customer_controller.dart';
import 'package:buildna/controller/nav_bar_controller.dart';
import 'package:buildna/view/auth/login.dart';
import 'package:buildna/view/customer/craftsmen_categories.dart';
import 'package:buildna/view/customer/craftsmen_list.dart';
import 'package:buildna/view/customer/profile_customer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../helpers/otp_session.dart';

class CustomerHome extends StatefulWidget {
  const CustomerHome({super.key});

  @override
  State<CustomerHome> createState() => _CustomerHomeState();
}

class _CustomerHomeState extends State<CustomerHome> {
  final AuthController authController = Get.find<AuthController>();
  final PageController _pageController = PageController();
  final locale = Get.locale;
  final NavBarController navController = Get.find<NavBarController>();
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Padding(
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
                        Get.put(CustomerController());
                        Get.to(() => CustomerProfilePage());
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
                    onPressed: () async {
                      await OtpSession.clear();
                      await FirebaseAuth.instance.signOut();
                      Get.offAll(() => LoginPage());
                    },
                    icon: const Icon(Icons.logout, color: Colors.black),
                  ),
                ],
              ),
              SizedBox(height: height * 0.03),
              SizedBox(
                height: height * 0.23,
                child: PageView(
                  controller: _pageController,
                  children: List.generate(
                    4,
                    (index) => _showPageView(height, width),
                  ),
                ),
              ),
              SizedBox(height: height * 0.015),
              SmoothPageIndicator(
                controller: _pageController,
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
                      '${'soon'.tr} 🔒',
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
                      await (authController.user as CustomerController)
                          .getAllCraftsmenCategories();
                      Get.to(() => CraftsmenCategories());
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
              SizedBox(
                height: height * 0.22,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount:
                      (authController.user as CustomerController)
                          .craftsmen2Categories
                          .length,
                  itemBuilder: (context, index) {
                    final item =
                        (authController.user as CustomerController)
                            .craftsmen2Categories[index];
                    return Container(
                      margin: EdgeInsets.only(right: width * 0.04),
                      padding: EdgeInsets.all(width * 0.02),
                      width: width * 0.4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          ClickableImage(
                            imagePath: item['picture_url'] ?? '',
                            height: height * 0.1,
                            width: double.infinity,
                            onTap: () async {
                              await (authController.user as CustomerController)
                                  .getAllCraftsmen(item['english_name']!);
                              Get.to(
                                () => CraftsmenList(
                                  speciality: item['english_name']!,
                                ),
                              );
                            },
                          ),
                          SizedBox(height: height * 0.01),
                          Text(
                            locale!.languageCode == 'en'
                                ? item['english_name'] ?? ''
                                : item['arabic_name'] ?? '',
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
              ),
            ],
          ),
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
