import 'package:buildna/controller/auth_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../helpers/otp_session.dart';
class StartupController extends GetxController {
  Future<bool> boot() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    final trusted = await OtpSession.isTrusted();
    if (!trusted) {
      await FirebaseAuth.instance.signOut();
      return false;
    }

    final userData = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (!userData.exists) return false;

    final authController = Get.find<AuthController>();
    authController.determainController(userData['role']); // navigates inside
    return true;
  }
}
