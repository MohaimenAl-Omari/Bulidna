import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VerficationPage extends StatelessWidget {
  const VerficationPage({super.key});

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Get.back(),
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
            Image.asset('assets/static/time-left.png', height: height * 0.18),
            const SizedBox(height: 24),
            const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Wait for your information to be \nVerificated',
                    textAlign: TextAlign.center,
                    style: TextStyle(
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
                  SizedBox(height: 16), // spacing between texts
                  Text(
                    'It will take approximately 48 hours to verify the\ninformation submitted',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.normal,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: height * 0.065),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
