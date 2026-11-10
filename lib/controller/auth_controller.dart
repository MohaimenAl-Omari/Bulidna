import 'dart:io';
import 'package:buildna/controller/admin_controller.dart';
import 'package:buildna/controller/craftsman_controller.dart';
import 'package:buildna/controller/customer_controller.dart';
import 'package:buildna/controller/nav_bar_controller.dart';
import 'package:buildna/controller/notifications_controller.dart';
import 'package:buildna/controller/user_controller.dart';
import 'package:buildna/view/admin/admin_home.dart';
import 'package:buildna/view/auth/select_category.dart';
import 'package:buildna/view/auth/verify_otp.dart';
import 'package:buildna/view/craftsman/Accepted_craftsman_page.dart';
import 'package:buildna/view/craftsman/main_craftsman_screen.dart';
import 'package:buildna/view/craftsman/rejected_craftsmna_page.dart';
import 'package:buildna/view/craftsman/verfication_page.dart';
import 'package:buildna/view/customer/main_customer_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../helpers/otp_session.dart';

class AuthController extends GetxController {
  final GlobalKey<FormState> authKey = GlobalKey<FormState>();
  final GlobalKey<FormState> signUpKeyUser = GlobalKey<FormState>();
  final GlobalKey<FormState> signUpKeyCraftsman = GlobalKey<FormState>();
  final GlobalKey<FormState> signUpKeyCraftsman2 = GlobalKey<FormState>();
  var locale = Get.locale;
  late UserController user;
  late CraftsmanController craftman;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _verificationId;
  RxInt duration = 60.obs;
  RxInt isaccepted = 0.obs; // 0 --> pending , 1--> accrepted , 2 --> rejected
  RxString phoneNumber = ''.obs;
  RxList<Map<String, dynamic>> craftsmanAppointments =
      <Map<String, dynamic>>[].obs;
  final ImagePicker picker = ImagePicker();
  Rx<XFile?> image = Rx<XFile?>(null);
  Rx<XFile?> frontID = Rx<XFile?>(null);
  Rx<XFile?> backID = Rx<XFile?>(null);
  NotificationsController notificationsController = Get.put(
    NotificationsController(),
  );
  RxList<String> specialities = <String>[].obs;
  RxBool isLoadingAppointments = false.obs;
  RxList<Map<String, dynamic>> lastTwoAppointments =
      <Map<String, dynamic>>[].obs;

  /// 🔐 Send OTP
  Future<void> sendOTP({
    required String phoneNumber,
    required BuildContext context,
  }) async {
    this.phoneNumber.value = phoneNumber;
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) async {
        Get.snackbar('Error', e.message!);
      },
      codeSent: (String verificationId, int? resendToken) {
        _verificationId = verificationId;
        Get.to(() => VerifyOtpPage(verifyCode: _verificationId));
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        _verificationId = verificationId;
      },
    );
  }

  Future<void> pickImageFromGallery(Rx<XFile?> image) async {
    image.value = await picker.pickImage(source: ImageSource.gallery);
  }

  /// ✅ Customer Sign-Up
  Future<void> createCustomer(
    String name,
    String email,
    String secondNumber,
    String gender,
    String city,
  ) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('No authenticated Firebase user');
      }

      String uid = currentUser.uid;
      String ext = p.extension(image.value!.path).replaceFirst('.', '');

      // Upload profile image
      String? imageUrl;
      if (image.value != null) {
        final ref = FirebaseStorage.instance
            .ref()
            .child('profile_pics')
            .child('$uid.$ext');
        final uploadTask = ref.putFile(File(image.value!.path));
        await uploadTask;
        imageUrl = await ref.getDownloadURL();
      }

      // Create user doc
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'username': name,
        'email': email,
        'phonenumber': currentUser.phoneNumber ?? '',
        'SecPhoneNum': secondNumber,
        'gender': gender,
        'city': city,
        'ImageURL': imageUrl ?? '',
        'role': 'customer',
        'IsDeleted': false,
      });

      // Create customer doc
      await FirebaseFirestore.instance.collection('customers').doc(uid).set({
        'Gender': gender,
      });

      await notificationsController.assignTokenToUser();

      user = Get.put(CustomerController());
      await user.loadUserData();
      Get.offAll(() => MainCustomerScreen());
    } catch (e) {
      Get.snackbar('Error', '${e}Failed to create customer account');
    }
  }

  /// 💾 Set Craftsman Data
  void setCraftsmanData({
    required String name,
    required String email,
    required String secondNumber,
    required String gender,
    required String city,
    required String description,
    required String idPostUrl,
    required String idBackUrl,
    required String speciality,
    required String profileUrl,
  }) {
    user = Get.put(CraftsmanController());
    final craftsman = user as CraftsmanController;
    craftsman.username.value = name;
    craftsman.email.value = email;
    craftsman.secPhoneNum.value = secondNumber;
    craftsman.gender.value = gender;
    craftsman.city.value = city;
    craftsman.description.value = description;
    craftsman.idpost.value = idPostUrl;
    craftsman.idback.value = idBackUrl;
    craftsman.speciality.value = speciality;
    craftsman.imageURL.value = profileUrl;
  }

  /// 🛠️ Create Craftsman
  Future<void> createCraftsman(String description) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) throw Exception('User not logged in');
      String uid = currentUser.uid;

      // Image upload helper
      Future<String?> uploadImage(XFile? file, String folderName) async {
        if (file == null) return null;
        String ext = p.extension(file.path).replaceFirst('.', '');
        final ref = FirebaseStorage.instance
            .ref()
            .child(folderName)
            .child('$uid-${DateTime.now().millisecondsSinceEpoch}.$ext');
        final uploadTask = ref.putFile(File(file.path));
        await uploadTask;
        return await ref.getDownloadURL();
      }

      String? profileUrl = await uploadImage(image.value, 'profile_pics');
      String? idFrontUrl = await uploadImage(frontID.value, 'id_front');
      String? idBackUrl = await uploadImage(backID.value, 'id_back');
      // Set data
      setCraftsmanData(
        name: user.username.value,
        email: user.email.value,
        secondNumber: user.secPhoneNum.value,
        gender: user.gender.value,
        city: user.city.value,
        description: description,
        idPostUrl: idFrontUrl ?? '',
        idBackUrl: idBackUrl ?? '',
        speciality: (user as CraftsmanController).speciality.value,
        profileUrl: profileUrl!,
      );

      // Store in Firestore
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'username': user.username.value,
        'email': user.email.value,
        'phonenumber': currentUser.phoneNumber ?? '',
        'SecPhoneNum': user.secPhoneNum.value,
        'gender': user.gender.value,
        'city': user.city.value,
        'ImageURL': profileUrl,
        'role': 'craftsman',
        'IsDeleted': false,
      });

      await FirebaseFirestore.instance.collection('craftsmen').doc(uid).set(<String,String>{
        'Gender': user.gender.value,
        'Description': description,
        'CardFront': idFrontUrl ?? '',
        'CardBack': idBackUrl ?? '',
        'Speciality': (user as CraftsmanController).speciality.value,
        'is_accepted': isaccepted.value.toString(),
      });
      // await setupFCMToken(); // Save the token in Firestore
      final token = await FirebaseMessaging.instance.getToken();
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'fcmToken': token,
      });

      Get.snackbar('Success', 'Craftsman account created!');
      await notificationsController.assignTokenToUser();
      if (isaccepted.value == 0) {
        Get.offAll(() => const VerficationPage());
      } else if (isaccepted.value == 1) {
        // Get.to(() => (MainCraftsmanScreen()));
        Get.to(() => const AcceptedCraftsmanPage());
      } else if (isaccepted.value == 2) {
        Get.to(() => const RejectedCraftsmanPage());
      }

      // Navigate as needed here
    } catch (e) {
      print(e);
      Get.snackbar('Error', '${e}Failed to create craftsman account');
    }
  }

  /// 🧪 OTP Verification
  Future<void> verifyOTP({required String smsCode, required verifyCode}) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId ?? '',
        smsCode: smsCode,
      );
      final userCredential = await _auth.signInWithCredential(credential);
      OtpSession.markTrustedFor30Days();
      final User? user = userCredential.user;
      if (user != null) {
        final userData =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .get();
        if (userData.exists) {
          determainController(userData['role']);
        } else {
          Get.offAll(() => SelectCategory());
        }
      }
    } on FirebaseAuthException catch (e) {
      // This block runs if verification fails or the code is invalid
      if (e.code == 'invalid-verification-code') {
        // Handle invalid code
        Get.snackbar('Error', '${e}The OTP is invalid. Please try again.');
      } else if (e.code == 'session-expired') {
        // Handle expired session
        Get.snackbar('Error', e.message!);
      } else {
        // Generic error
        Get.snackbar('Error', "${e} ${e.message ?? 'Verification failed.'}");
      }
    } catch (e) {
      // Handle any other errors
      Get.snackbar('Error', '${e}Something went wrong. Please try again.');
    }
  }

  /// ✅ Load Specialities
  Future<void> loadSpecialities() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('profession').get();
      specialities.value =
          snapshot.docs.map((doc) {
            final en = doc['english_name'];
            final ar = doc['arabic_name'];
            return '$en - $ar';
          }).toList();
    } catch (e) {
      Get.snackbar('Error', 'Error loading specialities');
    }
  }

  void determainController(String role) async {
    // await notificationsController.assignTokenToUser();
    if (role == 'craftsman') {
      user = Get.put(CraftsmanController());
      await user.loadUserData();
      await (user as CraftsmanController).loadCraftmandata();
      await getLastTwoAppointments();
      int isAccepted = (user as CraftsmanController).isAccepted.value;
      if (isAccepted == 0) {
        Get.to(() => const VerficationPage());
      } else if (isAccepted == 1) {
        Get.offAll(() => MainCraftsmanScreen());
      } else if (isAccepted == 2) {
        Get.to(() => const RejectedCraftsmanPage());
      }
    } else if (role == 'customer') {
      Get.put(NavBarController());
      user = Get.put(CustomerController());
      await (user as CustomerController).loadUserData();
      await (user as CustomerController).getFirstTwoCraftsmenCategories();
      Get.offAll(() => MainCustomerScreen());
    } else if (role == 'admin') {
      user = Get.put(AdminController());
      await (user as AdminController).loadUserData();
      await (user as AdminController).getPendingCraftsmen();
      Get.offAll(() => const AdminHome());
    }
  }

  /// 📱 Validate Jordanian Phone Number
  String? phoneValidator(value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    final RegExp jordanPhoneRegExp = RegExp(r'^\+9627[789]\d{7}$');
    if (!jordanPhoneRegExp.hasMatch(value)) {
      return 'Enter a valid Jordanian phone number that starts with +962';
    }
    return null;
  }

  Future<Map<String, dynamic>?> getAppointment(String appointmentId) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      DocumentSnapshot appointmentDoc =
          await firestore.collection('appointments').doc(appointmentId).get();
      if (appointmentDoc.exists) {
        final data = appointmentDoc.data() as Map<String, dynamic>;
        return data; // Return the full appointment data
      } else {
        Get.snackbar('Error', 'Appointment not found.');

        return null;
      }
    } catch (e) {
      Get.snackbar('Error', 'Error getting appointment');

      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getIncompleteAppointments() async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    try {
      QuerySnapshot snapshot =
          await firestore
              .collection('appointments')
              .where('completed', isEqualTo: false)
              .where(
                'craftsman_id',
                isEqualTo: FirebaseAuth.instance.currentUser!.uid,
              )
              .get();
      List<Map<String, dynamic>> appointments =
          snapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            data['appointment_id'] = doc.id; // ✅ correct!
            return data;
          }).toList();
      for (var i = 0; i < appointments.length; i++) {
        final customer =
            await firestore
                .collection('users')
                .doc(appointments[i]['customer_id'])
                .get();
        if (!customer.exists) continue;

        appointments[i]['username'] = customer.get('username');
        appointments[i]['id'] = customer.id;
      }
      craftsmanAppointments.assignAll(appointments);
      return appointments.toList();
    } catch (e) {
      Get.snackbar('Error', 'Error fetching incomplete appointments');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getCompleteAppointments() async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    try {
      QuerySnapshot snapshot =
          await firestore
              .collection('appointments')
              .where('completed', isEqualTo: true)
              .where(
                'craftsman_id',
                isEqualTo: FirebaseAuth.instance.currentUser!.uid,
              )
              .get();
      List<Map<String, dynamic>> appointments =
          snapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            data['appointment_id'] = doc.id; // ✅ correct!
            return data;
          }).toList();
      for (var i = 0; i < appointments.length; i++) {
        final customer =
            await firestore
                .collection('users')
                .doc(appointments[i]['customer_id'])
                .get();
        if (!customer.exists) continue;
        appointments[i]['username'] = customer.get('username');
        appointments[i]['id'] = customer.id;
      }
      craftsmanAppointments.assignAll(appointments);
      return appointments.toList();
    } catch (e) {
      Get.snackbar('Error', 'Error fetching incomplete appointments');
      return [];
    }
  }

  Future<void> sendMessage(
    String receiverID,
    String chatID,
    String messageText,
  ) async {
    final senderID = FirebaseAuth.instance.currentUser!.uid;
    await FirebaseFirestore.instance
        .collection('chat')
        .doc(chatID)
        .collection('messages')
        .add({
          'senderID': senderID,
          'receiverID': receiverID,
          'text': messageText,
          'createdAt': FieldValue.serverTimestamp(),
        });

    // Optionally, update the parent chat with last message:
    await FirebaseFirestore.instance.collection('chat').doc(chatID).update({
      'lastMessage': messageText,
      'lastMessageTime': FieldValue.serverTimestamp(),
    });
  }

  Future<File> loadImageFromNetwork(String url) async {
    final httpClient = HttpClient();
    final request = await httpClient.getUrl(Uri.parse(url));
    final response = await request.close();
    final bytes = await consolidateHttpClientResponseBytes(response);
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/profile_image.jpg');
    await file.writeAsBytes(bytes);
    return file;
  }

  Future<void> saveContactUs({
    required String fullName,
    required String email,
    required String issue,
  }) async {
    try {
      await FirebaseFirestore.instance.collection('support_requests').add({
        'fullName': fullName,
        'email': email,
        'issue': issue,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      Get.snackbar('Error', 'Failed to submit contact form');
      rethrow;
    }
  }

  Future<void> getAllAppointmentsForCustomer() async {
    final String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    isLoadingAppointments.value = true;

    try {
      final snapshot =
          await FirebaseFirestore.instance
              .collection('appointments')
              .where('customer_id', isEqualTo: userId)
              .get();

      List<Map<String, dynamic>> appointments = [];

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final craftsmanId = data['craftsman_id'];

        final craftsmanDoc =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(craftsmanId)
                .get();

        final craftsmanData =
            craftsmanDoc.exists ? craftsmanDoc.data() ?? {} : {};

        appointments.add({
          ...data,
          'appointment_id': doc.id,
          'craftsman_id': craftsmanId,
          'craftsman_username': craftsmanData['username'] ?? 'Unknown',
          'craftsman_image_url': craftsmanData['ImageURL'] ?? '',
          'craftsman_phone': craftsmanData['phonenumber'] ?? '',
          'craftsman_city': craftsmanData['city'] ?? '',
        });
      }

      craftsmanAppointments.assignAll(appointments);
    } catch (e) {
      Get.snackbar('Error', 'Error fetching appointments');
    } finally {
      isLoadingAppointments.value = false;
    }
  }

  Future<void> getLastTwoAppointments() async {
    try {
      final userId = FirebaseAuth.instance.currentUser!.uid;
      final querySnapshot =
          await FirebaseFirestore.instance
              .collection('appointments')
              .where('craftsman_id', isEqualTo: userId)
              .orderBy('createdAt', descending: true)
              .limit(2)
              .get();

      final appointments = await Future.wait(
        querySnapshot.docs.map((doc) async {
          final data = doc.data();
          final customerSnapshot =
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(doc['customer_id'])
                  .get();

          final customerData = customerSnapshot.data();
          data['username'] = customerData?['username'] ?? 'Unknown';
          data['ImageURL'] = customerData?['ImageURL'] ?? 'Unknown';
          return data;
        }),
      );

      lastTwoAppointments.value = appointments;
    } catch (e) {
      Get.snackbar('Error', 'Error getting appointments ');
    }
  }

  Future<void> launchPhoneDialer(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    try {
      await launchUrl(launchUri);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to launch phone dialer: $e',
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  Future<void> deleteUserAccount() async {
    final auth = FirebaseAuth.instance;
    final firestore = FirebaseFirestore.instance;
    final uid = auth.currentUser?.uid;

    if (uid == null) return;
    try {
      final reviewDocs =
          await firestore
              .collection('craftsmen')
              .doc(uid)
              .collection('reviews')
              .get();
      for (var doc in reviewDocs.docs) {
        await doc.reference.delete();
      }
      final favoritesDocs =
          await firestore
              .collection('customer')
              .doc(uid)
              .collection('favorites')
              .get();
      for (var doc in favoritesDocs.docs) {
        await doc.reference.delete();
      }

      deleteAppointmentsForUid(uid);
      deleteChatsForUid(uid);

      await firestore
          .collection('craftsmen')
          .doc(uid)
          .delete()
          .catchError((_) {});
      await firestore
          .collection('customers')
          .doc(uid)
          .delete()
          .catchError((_) {});
      await firestore.collection('users').doc(uid).delete();
      await auth.currentUser!.delete();
      Get.snackbar('Note', 'User account and all related data deleted.');
    } catch (e) {
      Get.snackbar('Error', 'The account can not be deleted');
    }
  }

  Future<void> deleteChatsForUid(String uid) async {
    final firestore = FirebaseFirestore.instance;

    // Step 1: Get all chats where craftsmanID == uid
    final craftsmanChats =
        await firestore
            .collection('chat')
            .where('craftsmanID', isEqualTo: uid)
            .get();

    // Step 2: Get all chats where customerID == uid
    final customerChats =
        await firestore
            .collection('chat')
            .where('customerID', isEqualTo: uid)
            .get();

    // Merge results to avoid duplicates
    final allChats =
        {
          for (var doc in craftsmanChats.docs) doc.id: doc,
          for (var doc in customerChats.docs) doc.id: doc,
        }.values;

    // Step 3: Loop through each chat and delete its messages + chat doc
    for (var chatDoc in allChats) {
      // Get messages in this chat
      final messagesSnapshot =
          await chatDoc.reference.collection('messages').get();

      // Delete messages in a batch
      final batch = firestore.batch();
      for (var messageDoc in messagesSnapshot.docs) {
        batch.delete(messageDoc.reference);
      }

      // Delete the chat document itself
      batch.delete(chatDoc.reference);

      await batch.commit();
    }
  }

  Future<void> deleteAppointmentsForUid(String uid) async {
    final firestore = FirebaseFirestore.instance;

    // Query appointments where craftsman_id == uid
    final craftsmanAppointments =
        await firestore
            .collection('appointments')
            .where('craftsman_id', isEqualTo: uid)
            .get();

    // Query appointments where customer_id == uid
    final customerAppointments =
        await firestore
            .collection('appointments')
            .where('customer_id', isEqualTo: uid)
            .get();

    // Merge the results to avoid deleting the same doc twice
    final allDocs =
        {
          for (var doc in craftsmanAppointments.docs) doc.id: doc,
          for (var doc in customerAppointments.docs) doc.id: doc,
        }.values;

    // Delete them
    for (var doc in allDocs) {
      await doc.reference.delete();
    }
  }
}
