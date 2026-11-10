import 'dart:io';
import 'package:buildna/components/custom_button.dart';
import 'package:buildna/components/custom_text_field.dart';
import 'package:buildna/components/dropdownlist.dart';
import 'package:buildna/controller/auth_controller.dart';
import 'package:buildna/controller/craftsman_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// ignore: must_be_immutable
class CraftsmanProfile extends StatelessWidget {
  CraftsmanProfile({super.key}) {
    final AuthController authController = Get.find<AuthController>();
    (authController.user as CraftsmanController).loadBasicProfileData(
      nameController: nameController,
      emailController: emailController,
      phoneController: phoneController,
      cityController: cityController,
      descriptionController: descripotioncontriller,
      imageRx: authController.image,
    );
  }
  final _formKey = GlobalKey<FormState>();

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
  TextEditingController phoneController = TextEditingController();
  TextEditingController descripotioncontriller = TextEditingController();
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
              Text(
                'Edit Profile'.tr,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 32,
                ),
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
                          key: _formKey,
                          child: Column(
                            children: [
                              CustomTextField(
                                hint: 'JohnDoe',
                                label: 'Full Name'.tr,
                                textController: nameController,
                              ),
                              SizedBox(height: height / 60),
                              CustomTextField(
                                hint: 'youremail@domain.com',
                                label: 'Email'.tr,
                                textController: emailController,
                              ),
                              SizedBox(height: height / 60),
                              CustomTextField(
                                hint: 'Add your description',
                                label: 'Description'.tr,
                                textController: descripotioncontriller,
                                maxLines: 4,
                              ),
                              SizedBox(height: height / 60),
                              CustomTextField(
                                hint: '07xxxxxxxx',
                                label: 'Second Phone Number'.tr,
                                textController: phoneController,
                              ),
                              SizedBox(height: height / 60),

                              SizedBox(height: height / 60),
                              Dropdownlist<String>(
                                items: cities,
                                selectedItem:
                                    cities.contains(cityController.text)
                                        ? cityController.text
                                        : null,
                                onChanged: (value) {
                                  selectedCity = value!;
                                  cityController.text = selectedCity.trim();
                                },
                                itemLabelBuilder: (value) => value,
                                hintText: 'Select a city'.tr,
                              ),
                              SizedBox(height: height / 30),
                              CustomButton(
                                onPressed: () async {
                                  final c =
                                      (authController.user
                                          as CraftsmanController);
                                  c.username.value = nameController.text;
                                  c.email.value = emailController.text;
                                  c.secPhoneNum.value = phoneController.text;
                                  c.city.value = cityController.text;
                                  c.description.value =
                                      descripotioncontriller.text;

                                  // Save to Firebase
                                  await c.saveEditProfile();

                                  // Navigate or show confirmation
                                  Get.snackbar(
                                    'Success',
                                    'Profile updated successfully',
                                  );
                                },

                                text: 'Save Edit',
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
                        final imageUrl = authController.user.imageURL.value;

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
                                pickedImage != null
                                    ? ClipOval(
                                      child: Image.file(
                                        File(pickedImage.path),
                                        width: width / 4,
                                        height: width / 4,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                    : (imageUrl.isNotEmpty
                                        ? ClipOval(
                                          child: Image.network(
                                            imageUrl,
                                            width: width / 4,
                                            height: width / 4,
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                        : const Icon(
                                          Icons.camera_alt_outlined,
                                          size: 60,
                                        )),
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
