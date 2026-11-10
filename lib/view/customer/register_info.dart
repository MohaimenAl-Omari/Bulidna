import 'dart:io';

import 'package:buildna/components/custom_button.dart';
import 'package:buildna/components/custom_text_field.dart';
import 'package:buildna/components/dropdownlist.dart';
import 'package:buildna/controller/auth_controller.dart';
import 'package:buildna/helpers/validators.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// ignore: must_be_immutable
class RegisterInfo extends StatelessWidget {
  RegisterInfo({super.key});
  List<String> gender = ['Male', 'Female'];
  List<String> cities = [
    'Amman',
    'Zarqa',
    'Irbid',
    'Aqaba',
    'Madaba',
    'Salt',
    'Jerash',
    'Ajloun',
    'Karak',
    'Ma’an',
    'Tafilah',
    'Mafraq',
  ];
  String selectedGender = 'Male';
  String selectedCity = 'Amman';
  final AuthController authController = Get.find<AuthController>();
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController genderController = TextEditingController(text: 'Male');
  TextEditingController phoneController = TextEditingController();
  TextEditingController cityController = TextEditingController(text: 'Amman');

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
              SizedBox(height: height / 10),
              const Text(
                'Register your info',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 32),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: height / 17),
              Container(
                height: height,
                width: width,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(80),
                  boxShadow: [
                    // Top shadow
                    BoxShadow(
                      // ignore: deprecated_member_use
                      color: Colors.black.withOpacity(0.3),
                      offset: const Offset(0, -30),
                      blurRadius: 40,
                      spreadRadius: 20,
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.topCenter,
                  clipBehavior: Clip.none,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                        top: width / 8 + 20,
                      ), // radius + extra space
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: width / 20),
                        child: Form(
                          key: authController.signUpKeyUser,
                          child: Column(
                            children: [
                              CustomTextField(
                                hint: 'Full Name',
                                label: 'Full name',
                                textController: nameController,
                                validator: (p0) => fullNameValidator(p0),
                              ),
                              SizedBox(height: height / 60),
                              CustomTextField(
                                hint: 'youremail@domain.com',
                                label: 'Email',
                                textController: emailController,
                                validator: (p0) => emailValidator(p0),
                              ),
                              SizedBox(height: height / 60),
                              CustomTextField(
                                hint: '07xxxxxxxx',
                                label: 'Second phone number (optional)',
                                textController: phoneController,
                                validator: (p0) => secondPhoneValidator(p0),
                              ),
                              SizedBox(height: height / 60),
                              Dropdownlist<String>(
                                items: gender,
                                selectedItem: 'Male',
                                onChanged: (value) {
                                  selectedGender = value!;
                                  genderController.text = selectedGender.trim();
                                },
                                itemLabelBuilder: (value) => value,
                                hintText: 'Select a gender',
                              ),
                              SizedBox(height: height / 60),
                              Dropdownlist<String>(
                                items: cities,
                                selectedItem: 'Amman',
                                onChanged: (value) {
                                  selectedCity = value!;
                                  cityController.text = selectedCity.trim();
                                },
                                itemLabelBuilder: (value) => value,
                                hintText: 'Select a city',
                              ),
                              SizedBox(height: height / 30),
                              CustomButton(
                                onPressed: () {
                                  if (authController.image.value == null) {
                                    Get.snackbar(
                                      'Error',
                                      'You need to upload an image to continue',
                                    );
                                    return;
                                  }
                                  if (authController.signUpKeyUser.currentState!
                                      .validate()) {
                                    authController.createCustomer(
                                      nameController.text.trim(),
                                      emailController.text.trim(),
                                      phoneController.text.trim(),
                                      selectedGender.trim(),
                                      selectedCity.trim(),
                                    );
                                  }
                                },
                                text: 'Sign up',
                                height: height / 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // 👇 This is the overlapping circle
                    Positioned(
                      top: -(width / 8),
                      child: Obx(() {
                        final pickedImage = authController.image.value;
                        return InkWell(
                          onTap: () {
                            authController.pickImageFromGallery(
                              authController.image,
                            );
                          },
                          child: Container(
                            width: width / 4,
                            height: width / 4,
                            decoration: const BoxDecoration(
                              color: Color.fromARGB(255, 202, 202, 202),
                              shape: BoxShape.circle,
                            ),
                            child:
                                pickedImage == null
                                    ? const Icon(
                                      Icons.camera_alt_outlined,
                                      size: 60,
                                    )
                                    : ClipOval(
                                      child: Image.file(
                                        File(pickedImage.path),
                                        width: width / 4,
                                        height: width / 4,
                                        fit: BoxFit.fill,
                                      ),
                                    ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
