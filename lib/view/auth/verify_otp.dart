import 'package:buildna/components/custom_otp_timer.dart';
import 'package:buildna/controller/auth_controller.dart';
import 'package:buildna/controller/loader_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

// ignore: must_be_immutable
class VerifyOtpPage extends StatelessWidget {
  VerifyOtpPage({super.key, required this.verifyCode});
  final String? verifyCode;
  final AuthController authController = Get.find<AuthController>();
  final TextEditingController otpController = TextEditingController();
  bool showOtpDialog = false;
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
              Container(
                margin: EdgeInsets.only(top: height / 15),
                height: height / 12,
                width: width / 5,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      // ignore: deprecated_member_use
                      color: Colors.black.withOpacity(0.3),
                      offset: const Offset(10, 9), // negative Y for top
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    '* * * *',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
              //
              SizedBox(height: height / 7),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: width / 10),
                child: Text(
                  'otp text'.tr,
                  style: const TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 20,
                    height: 1.1,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: height / 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "${'verify otp'.tr}  ",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Icon(Icons.arrow_forward, size: 30),
                ],
              ),
              SizedBox(height: height / 20),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: width / 15),
                child: Directionality(
                  textDirection: TextDirection.ltr,
                  child: PinCodeTextField(
                    controller: otpController,
                    appContext: context,
                    length: 6,
                    onChanged: (value) {},
                    onCompleted: (value) async {
                      final loader = Get.find<LoaderController>();
                      loader.show();
                      await authController.verifyOTP(
                        verifyCode: verifyCode,
                        smsCode: otpController.text.trim(),
                      );
                      loader.hide();
                    },
                    keyboardType: TextInputType.number,
                    pinTheme: PinTheme(
                      // fieldOuterPadding: EdgeInsets.symmetric(horizontal: 10),
                      shape: PinCodeFieldShape.box,
                      borderRadius: BorderRadius.circular(5),
                      fieldHeight: height / 15,
                      fieldWidth: width / 8,
                      activeFillColor: Colors.white,
                      inactiveColor: const Color.fromARGB(161, 198, 198, 198),
                      selectedColor: const Color.fromARGB(159, 105, 105, 105),
                      activeColor: const Color.fromARGB(159, 105, 105, 105),
                    ),
                  ),
                ),
              ),
              CircularCountdown(
                seconds: authController.duration.value,
                onButtonPressed: () {
                  otpController.clear();
                  authController.sendOTP(
                    phoneNumber: authController.phoneNumber.value,
                    context: context,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
