import 'package:buildna/components/custom_button.dart';
import 'package:buildna/components/custom_clickable_image.dart';
import 'package:buildna/controller/auth_controller.dart';
import 'package:buildna/controller/customer_controller.dart';
import 'package:buildna/view/customer/craftsman_details.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CraftsmenList extends StatelessWidget {
  CraftsmenList({super.key, required this.speciality});
  final AuthController authController = Get.find<AuthController>();
  final String speciality;
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          speciality,
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
        padding: EdgeInsets.symmetric(
          horizontal: width / 30,
          vertical: width / 30,
        ),
        child: ListView.builder(
          itemCount:
              (authController.user as CustomerController).craftsmen.length,
          itemBuilder: (context, index) {
            final item =
                (authController.user as CustomerController).craftsmen[index];
            String desc = item['Description'] ?? '';
            String shortDesc =
                desc.length > 40 ? '${desc.substring(0, 40)}....' : desc;
            return Container(
              height: height / 4.6,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 248, 245, 248),
                borderRadius: BorderRadius.circular(16),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: width / 30,
                vertical: width / 30,
              ),
              child: Row(
                children: [
                  ClickableImage(
                    imagePath: item['ImageURL'] ?? '',
                    height: height / 5.5,
                    width: width / 3.5,
                    onTap: () {},
                  ),
                  SizedBox(width: width / 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: height / 1000),
                        Text(
                          item['username']!.capitalize ?? 'N/A',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                          ),
                        ),
                        SizedBox(height: height / 100),
                        Text(
                          item['Speciality'] ?? 'N/A',
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                        ),
                        SizedBox(height: height / 100),
                        if ((item['Description'] ?? '').isNotEmpty)
                          Text(
                            shortDesc,
                            maxLines: 3,
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                            ),
                          ),
                        SizedBox(height: height / 100),
                        Container(
                          margin: EdgeInsets.only(right: width / 4),
                          child: CustomButton(
                            onPressed: () async {
                              await (authController.user as CustomerController)
                                  .getOneCraftsman(item['id']!);
                              Get.to(() => CraftsmanDetails());
                            },
                            text: 'Book'.tr,
                            height: height / 30,
                            fontSize: 17,
                            borderRadius: 8,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
