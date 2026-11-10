import 'dart:io';
import 'package:buildna/controller/auth_controller.dart';
import 'package:buildna/controller/user_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class CraftsmanController extends UserController {
  // data of craftsman:
  RxString id = ''.obs;
  RxString description = ''.obs;
  RxString speciality = ''.obs;
  RxString idpost = ''.obs;
  RxString idback = ''.obs;
  RxString from = ''.obs;
  RxString to = ''.obs;
  RxInt isAccepted = 0.obs;
  RxList<String> selectedDays = [''].obs;
  RxList<Map<String, dynamic>> appointments = <Map<String, dynamic>>[].obs;
  Map<String, dynamic> pickedCustomer = {};
  Map<String, String> pickedCustomer2 = {};

  // clear all values of user:
  @override
  void clearUser() {
    speciality.value = '';
    description.value = '';
    idpost.value = '';
    idback.value = '';
  }



  Future<void> loadCraftmandata() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) {
        throw Exception('User not logged in');
      }

      final doc =
          await FirebaseFirestore.instance
              .collection('craftsmen')
              .doc(uid)
              .get();

      if (doc.exists) {
        final data = doc.data()!;
        speciality.value = data['Speciality'] ?? '';
        speciality.value = data['speciality'] ?? '';
        description.value = data['description'] ?? '';
        idpost.value = data['idpost'] ?? '';
        idback.value = data['idback'] ?? '';
        from.value = data['from'] ?? '';
        to.value = data['to'] ?? '';
        selectedDays.value = List<String>.from(data['days']??[]);
        isAccepted.value = int.parse(data['is_accepted'] ?? 0);
      } else {
        Get.snackbar('Error', 'User document does not exist.');
      }
    } catch (e) {
      Get.snackbar('Error', 'Error loading user data.');
    }
  }

  Future<void> addSchedule(String from, String to, List days) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    try {
      await FirebaseFirestore.instance
          .collection('craftsmen')
          .doc(uid) // 👈 the craftsman to update
          .set(
            {'from': from, 'to': to, 'days': days},
            SetOptions(merge: true),
          ); // merge = only update this part, don't overwrite entire doc
      Get.snackbar(
        'Success',
        'Schedule saved',
        snackPosition: SnackPosition.TOP,
        colorText: Colors.black,
        duration: const Duration(seconds: 2),
      );
      this.to.value = to;
      this.from.value = from;
      selectedDays.value = List<String>.from(days);
    } catch (e) {
      Get.snackbar(
        colorText: Colors.black,
        'Error',
        'Failed to save schedule',
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  // to retrive all apointments:
  Future<void> getAppointments(String craftsmanId) async {
    final snapshot =
        await FirebaseFirestore.instance
            .collection('appointments')
            .where('craftsmanId', isEqualTo: craftsmanId)
            .get();

    appointments.value = snapshot.docs.map((doc) => doc.data()).toList();
  }

  Future<void> loadBasicProfileData({
    required TextEditingController nameController,
    required TextEditingController emailController,
    required TextEditingController phoneController,
    required TextEditingController cityController,
    required TextEditingController descriptionController,
    required Rx<XFile?> imageRx,
  }) async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) throw Exception('No user logged in');

      final userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final craftsmanDoc =
          await FirebaseFirestore.instance
              .collection('craftsmen')
              .doc(uid)
              .get();

      if (userDoc.exists) {
        final data = userDoc.data()!;
        nameController.text = data['username'] ?? '';
        emailController.text = userDoc['email'] ?? '';
        phoneController.text = userDoc['SecPhoneNum'] ?? '';
        cityController.text = data['City'] ?? 'Amman';
        descriptionController.text = craftsmanDoc['Description'] ?? '';
        username.value = nameController.text;
        email.value = emailController.text;
        secPhoneNum.value = phoneController.text;
        city.value = cityController.text;
        // Load image if available
        final imageUrl = data['ImageURL'];
        if (imageUrl != null && imageUrl.toString().isNotEmpty) {
          final file = await Get.find<AuthController>().loadImageFromNetwork(
            imageUrl,
          );
          imageRx.value = XFile(file.path);
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load profile data');
    }
  }

  Future<void> saveEditProfile() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) throw Exception('No user logged in');

      String? imageUrl;
      final pickedImage = Get.find<AuthController>().image.value;

      if (pickedImage != null) {
        final storageRef = FirebaseStorage.instance.ref().child(
          'profile_pictures/$uid.jpg',
        );
        await storageRef.putFile(File(pickedImage.path));
        imageUrl = await storageRef.getDownloadURL();
      }

      // Update 'users' collection
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'username': username.value,
        'email': email.value,
        'gender': gender.value,
        'city': city.value,
        if (imageUrl != null) 'ImageURL': imageUrl,
      }, SetOptions(merge: true));

      // Update 'craftsmen' collection
      await FirebaseFirestore.instance.collection('craftsmen').doc(uid).set({
        'Description': description.value,
        'SecPhoneNum': secPhoneNum.value,
      }, SetOptions(merge: true));

      if (imageUrl != null) {
        imageURL.value = imageUrl;
      }

      Get.snackbar('Success', 'Profile updated successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to save profile');
    }
  }

  Future<void> pickCustomer(String customerID) async {
    final doc =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(customerID)
            .get();
    final data = doc.data();
    if (doc.exists) {
      pickedCustomer['username'] = data?['username'];
      pickedCustomer['ImageURL'] = data?['ImageURL'];
      pickedCustomer['id'] = doc.id;
    }
  }

  Future<void> getOneCustomer(String id) async {
    //Unknown
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final userDoc = await firestore.collection('users').doc(id).get();
    // final data = userDoc.data()!;
    pickedCustomer = {
      'username': userDoc['username'],
      'customer_id': userDoc.id,
      'image_url': userDoc['ImageURL'],
      'phonenumber': userDoc['phonenumber'],
      'city': userDoc['city'],
      'email': userDoc['email'],
    };
  }

  Future<void> markAppointmentAsCompleted(String id) async {
    FirebaseFirestore.instance.collection('appointments').doc(id).set({
      'completed': true,
    }, SetOptions(merge: true));
  }
}
