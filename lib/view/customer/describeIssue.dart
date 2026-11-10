import 'dart:io';

import 'package:buildna/components/custom_button.dart';
import 'package:buildna/components/dottedborder.dart';
import 'package:buildna/components/dropdownlist.dart';
import 'package:buildna/controller/auth_controller.dart';
import 'package:buildna/controller/customer_controller.dart';
import 'package:buildna/view/customer/appointment_complete.dart';
import 'package:buildna/view/customer/craftsman_details.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class DescribeIssuePage extends StatefulWidget {
  const DescribeIssuePage({super.key});
  @override
  State<DescribeIssuePage> createState() => _DescribeIssuePageState();
}

class _DescribeIssuePageState extends State<DescribeIssuePage> {
  final TextEditingController _issueController = TextEditingController();
  AuthController authController = Get.find<AuthController>();
  XFile? _pickedImage;
  late TextEditingController _dayController;
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _pickedImage = image);
    }
  }

  @override
  void initState() {
    _dayController = TextEditingController(
      text:
          (authController.user as CustomerController)
              .pickedCraftsmanWorkDays[0],
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Describe the issue'.tr,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Get.off(() => CraftsmanDetails()),
          icon: const Icon(Icons.arrow_back_ios),
        ),
        centerTitle: true,
      ),
      body: Container(
        padding: EdgeInsets.symmetric(
          horizontal: width * 0.06,
          vertical: height * 0.02,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Choose a week day'.tr,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: height / 60),
              Dropdownlist(
                items:
                    (authController.user as CustomerController)
                        .pickedCraftsmanWorkDays,
                selectedItem:
                    (authController.user as CustomerController)
                        .pickedCraftsmanWorkDays[0],
                onChanged: (value) {
                  _dayController.text = value!;
                },
                itemLabelBuilder: (p0) {
                  return p0;
                },
              ),
              SizedBox(height: height / 60),
              Text(
                'Picture of the issue'.tr,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: height / 60),
              GestureDetector(
                onTap: _pickImage,
                child: DottedBorderContainer(
                  child:
                      _pickedImage != null
                          ? Image.file(
                            File(_pickedImage!.path),
                            height: height * 0.2,
                            width: double.infinity,
                            fit: BoxFit.fitWidth,
                          )
                          : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.upload,
                                size: 32,
                                color: Colors.grey,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Attach Pictures'.tr,
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                ),
              ),
              SizedBox(height: height / 18),
              Text(
                'Describe of the issue'.tr,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _issueController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'describe your issue here'.tr,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              // SizedBox(height: height / 10),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.symmetric(
          horizontal: width * 0.06,
          vertical: height * 0.02,
        ),
        child: CustomButton(
          onPressed: () async {
            if (_pickedImage == null) {
              Get.snackbar(
                colorText: Colors.black,
                'Error'.tr,
                'You must upload an image'.tr,
                snackPosition: SnackPosition.TOP,
              );
              return;
            }
            if (_issueController.text.isEmpty) {
              Get.snackbar(
                colorText: Colors.black,
                'Error'.tr,
                'You must write a description'.tr,
                
                snackPosition: SnackPosition.TOP,
              );
              return;
            }
            await (authController.user as CustomerController).addAppointment(
              _dayController.text,
              _issueController.text,
              _pickedImage!,
            );
            Get.to(() => AppointmentBookedPage());
          },
          text: 'Complete Appointment'.tr,
          height: height * 0.065,
        ),
      ),
    );
  }
}
