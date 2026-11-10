import 'package:buildna/components/custom_button.dart';
import 'package:buildna/view/auth/login.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RejectedCraftsmanPage extends StatelessWidget {
  const RejectedCraftsmanPage({super.key});
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: width * 0.06),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: height / 2.4),
                  const Text(
                    'The information you submited\nwas rejected!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 25,
                      shadows: [
                        Shadow(
                          offset: Offset(4, 8),
                          blurRadius: 12,
                          color: Colors.black26,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: height / 23),
            CustomButton(
              onPressed: () {
                Get.to(() => (LoginPage()));
              },
              text: 'Return to login page',
              height: height / 13,
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
