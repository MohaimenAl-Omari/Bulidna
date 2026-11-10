import 'dart:io';

import 'package:buildna/components/custom_button.dart';
import 'package:buildna/components/custom_text_field.dart';
import 'package:buildna/components/dropdownlist.dart';
import 'package:buildna/controller/auth_controller.dart';
import 'package:buildna/controller/craftsman_controller.dart';
import 'package:buildna/helpers/validators.dart';
import 'package:buildna/view/craftsman/register_info_craftsman_2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// ignore: must_be_immutable
class RegisterInfoCraftsman extends StatelessWidget {
  RegisterInfoCraftsman({super.key});
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
                'Register your info - craftsman',
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
                          key: authController.signUpKeyCraftsman,
                          child: Column(
                            children: [
                              CustomTextField(
                                hint: '',
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
                              SizedBox(height: height / 50),
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
                              SizedBox(height: height / 50),
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
                                  if (authController
                                      .signUpKeyCraftsman
                                      .currentState!
                                      .validate()) {
                                    authController.user = Get.put(
                                      CraftsmanController(),
                                    );
                                    final c =
                                        authController.user
                                            as CraftsmanController;
                                    c.username.value = nameController.text;
                                    c.email.value = emailController.text;
                                    c.secPhoneNum.value = phoneController.text;
                                    c.gender.value = genderController.text;
                                    c.city.value = cityController.text;

                                    // Go to Page 2
                                    Get.to(
                                      () => const RegisterInfoCraftsman2(),
                                    );
                                  }
                                },

                                text: 'Next',
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
