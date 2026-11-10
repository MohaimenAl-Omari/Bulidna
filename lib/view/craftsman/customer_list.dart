import 'package:buildna/components/custom_button.dart';
import 'package:buildna/components/custom_clickable_image.dart';
import 'package:buildna/controller/auth_controller.dart';
import 'package:buildna/view/craftsman/view_appointment.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomerList extends StatefulWidget {
  const CustomerList({super.key});

  @override
  State<CustomerList> createState() => _CustomerListState();
}

class _CustomerListState extends State<CustomerList> {
  final AuthController authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final RxString selectedFilter = 'Incompleted'.obs;
    return Scaffold(
      appBar: AppBar(
        elevation: 0, // no base shadow
        scrolledUnderElevation: 0, // no shadow when scrolling under
        surfaceTintColor: Colors.transparent, // disables extra shading
        centerTitle: true,
        title: Text(
          'All Appointments'.tr,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back_ios),
        ),
      ),
      body: Column(
        children: [
          SizedBox(height: height / 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Obx(
                () => CustomButton(
                  onPressed: () async {
                    await authController.getIncompleteAppointments();
                    selectedFilter.value = 'Incompleted';
                  },
                  text: 'Incompleted'.tr,
                  height: height / 25,
                  width: width / 2.6,
                  color:
                      selectedFilter.value == 'Incompleted'
                          ? Colors.black
                          : Colors.white,
                  textColor:
                      selectedFilter.value == 'Incompleted'
                          ? Colors.white
                          : Colors.black,
                ),
              ),
              Obx(
                () => CustomButton(
                  onPressed: () async {
                    await authController.getCompleteAppointments();
                    selectedFilter.value = 'Completed';
                  },
                  text: 'Completed'.tr,
                  height: height / 25,
                  width: width / 2.9,
                  color:
                      selectedFilter.value == 'Completed'
                          ? Colors.black
                          : Colors.white,
                  textColor:
                      selectedFilter.value == 'Completed'
                          ? Colors.white
                          : Colors.black,
                ),
              ),
            ],
          ),

          SizedBox(height: height / 40),
          Expanded(
            child: Obx(
              () => ListView.builder(
                padding: EdgeInsets.all(width / 30),
                itemCount: authController.craftsmanAppointments.length,
                itemBuilder: (context, index) {
                  final item = authController.craftsmanAppointments[index];
                  return Container(
                    margin: EdgeInsets.only(bottom: height / 40),
                    padding: EdgeInsets.all(width / 30),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 248, 245, 248),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ClickableImage(
                          imagePath: item['image_url'] ?? '',
                          height: height / 5.5,
                          width: width / 3.5,
                          onTap: () {},
                        ),
                        SizedBox(width: width / 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['username'] ?? 'Unknown',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 18,
                                ),
                              ),
                              SizedBox(height: height / 100),
                              Text(
                                'Day: ${item['reservation_day'] ?? 'N/A'}',
                                style: const TextStyle(fontSize: 12),
                              ),
                              SizedBox(height: height / 60),
                              // CustomButton(
                              //   onPressed: () async {
                              //     Get.to(() => Chat(customer: item));
                              //   },
                              //   text: 'Chat'.tr,
                              //   height: height / 30,
                              //   fontSize: 17,
                              //   borderRadius: 8,
                              // ),
                              CustomButton(
                                onPressed: () async {
                                  Get.to(
                                    () => ViewAppointment(appointment: item),
                                  );
                                },
                                text: 'View Appointment'.tr,
                                height: height / 30,
                                fontSize: 17,
                                borderRadius: 8,
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
          ),
        ],
      ),
    );
  }
}
