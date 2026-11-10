import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class UserController extends GetxController {
  // Rx variables for user data
  RxString email = ''.obs;
  RxString phoneNumber = ''.obs;
  RxBool isDeleted = false.obs;
  RxString city = ''.obs;
  RxString imageURL = ''.obs;
  RxString secPhoneNum = ''.obs;
  RxString username = ''.obs;
  RxString gender = ''.obs;

  // Load user data from Firestore
  Future<void> loadUserData() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) {
        throw Exception('User not logged in');
      }

      final doc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (doc.exists) {
        final data = doc.data()!;
        email.value = data['email'] ?? '';
        phoneNumber.value = data['phonenumber'] ?? '';
        isDeleted.value = data['IsDeleted'] ?? false;
        city.value = data['city'] ?? '';
        imageURL.value = data['ImageURL'] ?? '';
        secPhoneNum.value = data['SecPhoneNum'] ?? '';
        username.value = data['username'] ?? '';
        gender.value = data['gender'];
      }
    } catch (e) {
      Get.snackbar('Error', 'Error loading user data');
    }
  }

  // clear all values of user:
  void clearUser() {
    email.value = '';
    phoneNumber.value = '';
    isDeleted.value = false;
    city.value = '';
    imageURL.value = '';
    secPhoneNum.value = '';
    username.value = '';
  }
}
