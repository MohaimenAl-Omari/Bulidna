import 'package:buildna/components/custom_button.dart';
import 'package:buildna/view/craftsman/main_craftsman_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AcceptedCraftsmanPage extends StatelessWidget {
  const AcceptedCraftsmanPage({super.key});

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
                  SizedBox(height: height / 2.5),
                  const Text(
                    'Your information has been\nVerified',
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
                  const SizedBox(height: 16), // spacing between texts
                  const Text(
                    'Thank you for joining Buildna',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.normal,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: height / 23),
            CustomButton(
              onPressed: () {
                Get.to(() => (MainCraftsmanScreen()));
              },
              text: 'Go to Home Page',
              height: height / 13,
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
