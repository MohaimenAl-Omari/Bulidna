import 'package:buildna/controller/user_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class AdminController extends UserController {
  var pendingCraftsmen = <Map<String, dynamic>>[].obs;

  @override
  Future<void> loadUserData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final doc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (doc.exists) {
      final data = doc.data()!;
      phoneNumber.value = data['phonenumber'] ?? '';
    }
  }

  Future<void> getPendingCraftsmen() async {
    final snapshot =
        await FirebaseFirestore.instance
            .collection('craftsmen')
            .where('is_accepted', isEqualTo: '0')
            .get();

    List<Map<String, dynamic>> result = [];

    for (var doc in snapshot.docs) {
      var craftsmanData = doc.data();
      var userDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(doc.id)
              .get();

      if (userDoc.exists) {
        var userData = userDoc.data()!;
        result.add({'craftsmanId': doc.id, ...userData, ...craftsmanData});
      }
    }

    pendingCraftsmen.value = result;
  }

  Future<Map<String, dynamic>?> getCraftsmanFullData(String craftsmanId) async {
    final craftsmanDoc =
        await FirebaseFirestore.instance
            .collection('craftsmen')
            .doc(craftsmanId)
            .get();

    final userDoc =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(craftsmanId)
            .get();

    if (!craftsmanDoc.exists || !userDoc.exists) {
      return null;
    }

    return {...userDoc.data()!, ...craftsmanDoc.data()!};
  }

  Future<void> updateCraftsmanStatus(String craftsmanId, int status) async {
    await FirebaseFirestore.instance
        .collection('craftsmen')
        .doc(craftsmanId)
        .update({'is_accepted': status});
  }
}
