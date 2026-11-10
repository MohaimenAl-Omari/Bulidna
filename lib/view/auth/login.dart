import 'package:buildna/components/custom_button.dart';
import 'package:buildna/components/custom_text_field.dart';
import 'package:buildna/controller/auth_controller.dart';
import 'package:buildna/controller/loader_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});
  final AuthController authController = Get.find<AuthController>();
  final TextEditingController phoneController = TextEditingController(
    text: '+962',
  );
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: SizedBox(
        width: width,
        height: height,
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: height / 5),
              Text(
                'login greeting'.tr,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 32,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: height / 17),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(80),
                  boxShadow: [
                    // Top shadow
                    BoxShadow(
                      // ignore: deprecated_member_use
                      color: Colors.black.withOpacity(0.3),
                      offset: const Offset(0, -30), // negative Y for top
                      blurRadius: 40,
                      spreadRadius: 20,
                    ),
                    // Bottom shadow
                    BoxShadow(
                      // ignore: deprecated_member_use
                      color: Colors.black.withOpacity(0.4),
                      offset: const Offset(0, 30), // positive Y for bottom
                      blurRadius: 40,
                      spreadRadius: 20,
                    ),
                  ],
                ),
                child: Form(
                  key: authController.authKey,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: width / 15),
                    child: Column(
                      children: [
                        SizedBox(height: height / 15),
                        CustomTextField(
                          hint: '07xxxxxxxx',
                          label: 'phone label'.tr,
                          textController: phoneController,
                          validator: authController.phoneValidator,
                          maxLines: 1,
                        ),
                        SizedBox(height: height / 30),
                        CustomButton(
                          text: 'Sign In'.tr,
                          onPressed: () {
                            Get.snackbar('Wait 😊', 'Be patient , We will send you a message');
                            if (authController.authKey.currentState!
                                .validate()) {
                               authController.sendOTP(
                                phoneNumber: phoneController.text.trim(),
                                context: context,
                              );
                            }
                          },
                          height: height / 18,
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          alignment: WrapAlignment.center, // centers the sentence horizontally
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 0, // no space between the text and button
                          children: [
                            const Text(
                              'By continuing, You agree to',
                              style: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 13,
                              ),
                            ),
                            TextButton(
                              style: ButtonStyle(
                                padding: WidgetStateProperty.all(EdgeInsets.zero),
                                minimumSize: WidgetStateProperty.all(Size(0, 0)),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              onPressed: () async {
                                final Uri url = Uri.parse(
                                  'https://shaheen02.github.io/buildna-privacy-policy/',
                                );
                                if (!await launchUrl(url, mode: LaunchMode.platformDefault)) {
                                  throw Exception('Could not launch $url');
                                }
                              },
                              child: const Text(
                                ' Terms and conditions',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromARGB(255, 49, 98, 182),
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        )
                          ],
                        ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
