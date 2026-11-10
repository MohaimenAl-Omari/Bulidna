import 'package:buildna/components/custom_clickable_image.dart';
import 'package:buildna/controller/auth_controller.dart';
import 'package:buildna/controller/customer_controller.dart';
import 'package:buildna/view/customer/craftsmen_list.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CraftsmenCategories extends StatelessWidget {
  CraftsmenCategories({super.key});
  final AuthController authController = Get.find<AuthController>();
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'All Prefessions'.tr,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 22),
        ),
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: const Icon(Icons.arrow_back_ios),
        ),
      ),
      body: Container(
        height: height,
        width: width,
        padding: EdgeInsets.symmetric(
          horizontal: width / 12,
          vertical: height / 60,
        ),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 0,
            mainAxisExtent: height / 7,
            childAspectRatio: 1,
          ),
          itemCount:
              (authController.user as CustomerController)
                  .craftsmenCategories
                  .length,
          itemBuilder: (context, index) {
            final item =
                (authController.user as CustomerController)
                    .craftsmenCategories[index];
            return ClickableImage(
              imagePath: item['picture_url'] ?? '',
              height: height / 9.5,
              width: width / 2.7,
              text:
                  Get.locale?.languageCode == 'en'
                      ? item['english_name']
                      : item['arabic_name'],
              onTap: () async {
                await (authController.user as CustomerController)
                    .getAllCraftsmen(item['english_name']!);
                Get.to(() => CraftsmenList(speciality: item['english_name']!));
              },
            );
          },
        ),
      ),
    );
  }
}
