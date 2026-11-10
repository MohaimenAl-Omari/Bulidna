import 'dart:io';
import 'package:buildna/components/custom_button.dart';
import 'package:buildna/components/custom_text_field.dart';
import 'package:buildna/components/dottedborder.dart';
import 'package:buildna/components/dropdownlist.dart';
import 'package:buildna/controller/auth_controller.dart';
import 'package:buildna/controller/craftsman_controller.dart';
import 'package:buildna/helpers/validators.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RegisterInfoCraftsman2 extends StatefulWidget {
  const RegisterInfoCraftsman2({super.key});

  @override
  State<RegisterInfoCraftsman2> createState() => _RegisterInfoCraftsman2State();
}

class _RegisterInfoCraftsman2State extends State<RegisterInfoCraftsman2> {
  final AuthController authController = Get.find<AuthController>();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController specialityController = TextEditingController();

  String selectedSpeciality = '';

  @override
  void initState() {
    super.initState();
    authController.loadSpecialities();
  }

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
                'Complete your info',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 32),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: height / 15),
              Container(
                width: width,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(80),
                  boxShadow: [
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
                      padding: EdgeInsets.only(top: width / 8 + 20),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: width / 20),
                        child: Form(
                          key: authController.signUpKeyCraftsman2,
                          child: Column(
                            children: [
                              CustomTextField(
                                hint: 'Write here...',
                                label: 'Add a description',
                                textController: descriptionController,
                                maxLines: 6,
                                validator: (p0) => descriptionValidator(p0),
                              ),
                              SizedBox(height: height / 30),
                              Obx(() {
                                final list = authController.specialities;
                                return Dropdownlist<String>(
                                  items: list,
                                  selectedItem:
                                      list.isNotEmpty ? list.first : null,
                                  onChanged: (value) {
                                    selectedSpeciality = value!;
                                    specialityController.text = value;
                                    final c =
                                        authController.user
                                            as CraftsmanController;
                                    c.speciality.value = value;
                                  },
                                  itemLabelBuilder: (value) => value,
                                  hintText: 'Select your speciality',
                                );
                              }),
                              SizedBox(height: height / 30),
                              Obx(
                                () => Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        authController.pickImageFromGallery(
                                          authController.frontID,
                                        );
                                      },
                                      child: SizedBox(
                                        width: width / 2.5,
                                        height: width / 4,
                                        child: DottedBorderContainer(
                                          child:
                                              authController.frontID.value ==
                                                      null
                                                  ? const Text(
                                                    'Front Side ID',
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  )
                                                  : Image.file(
                                                    File(
                                                      authController
                                                          .frontID
                                                          .value!
                                                          .path,
                                                    ),
                                                    fit: BoxFit.cover,
                                                    width: double.infinity,
                                                    height: double.infinity,
                                                  ),
                                        ),
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        authController.pickImageFromGallery(
                                          authController.backID,
                                        );
                                      },
                                      child: SizedBox(
                                        width: width / 2.5,
                                        height: width / 4,
                                        child: DottedBorderContainer(
                                          child:
                                              authController.backID.value ==
                                                      null
                                                  ? const Text(
                                                    'Back Side ID',
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  )
                                                  : Image.file(
                                                    File(
                                                      authController
                                                          .backID
                                                          .value!
                                                          .path,
                                                    ),
                                                    fit: BoxFit.cover,
                                                    width: double.infinity,
                                                    height: double.infinity,
                                                  ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: height / 20),
                              CustomButton(
                                onPressed: ()async {
                                  if (authController.frontID.value == null) {
                                    Get.snackbar(
                                      'Error',
                                      'Front Side ID is required to upload',
                                    );
                                    return;
                                  }
                                  if (authController.backID.value == null) {
                                    Get.snackbar(
                                      'Error',
                                      'Back Side ID is required to upload',
                                    );
                                    return;
                                  }
                                  final c =
                                      authController.user
                                          as CraftsmanController;
                                  c.description.value =
                                      descriptionController.text;
                                  if (authController
                                      .signUpKeyCraftsman2
                                      .currentState!
                                      .validate()) {
                                    await authController.createCraftsman(
                                      descriptionController.text,
                                    );
                                  }
                                },
                                text: 'Sign up',
                                height: height / 20,
                              ),
                              SizedBox(height: height / 20),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Profile image
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
                                        fit: BoxFit.cover,
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
