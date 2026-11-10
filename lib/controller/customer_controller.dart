import 'dart:io';
import 'package:buildna/controller/user_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;

class CustomerController extends UserController {
  List<Map<String, String>> craftsmenCategories = [];
  List<Map<String, String>> craftsmen2Categories = [];
  List<Map<String, String>> craftsmen = [];
  Map<String, String> pickedCraftsman = {};
  List<String> pickedCraftsmanWorkDays = [];
  List<String> craftsmanWorkDays = [];
  var isCraftsmanFavorite = false.obs;
  RxList<Map<String, dynamic>> favoriteCraftsmen = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> reviews = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> craftsmanAppointments =
      <Map<String, dynamic>>[].obs;

  Future<List<DocumentSnapshot>> getFirstTwoCraftsmenCategories() async {
    craftsmen2Categories.clear();
    final snapshot =
        await FirebaseFirestore.instance
            .collection('profession')
            .limit(2)
            .get();
    for (var doc in snapshot.docs) {
      craftsmen2Categories.add({
        'english_name': doc['english_name'],
        'arabic_name': doc['arabic_name'],
        'picture_url': doc['picture_url'],
      });
    }
    return snapshot.docs;
  }

  Future<List<DocumentSnapshot>> getAllCraftsmenCategories() async {
    craftsmenCategories.clear();
    final snapshot =
        await FirebaseFirestore.instance.collection('profession').get();
    for (var doc in snapshot.docs) {
      craftsmenCategories.add({
        'english_name': doc['english_name'],
        'arabic_name': doc['arabic_name'],
        'picture_url': doc['picture_url'],
      });
    }
    return snapshot.docs;
  }

  Future<List<DocumentSnapshot>> getAllCraftsmen(String category) async {
    craftsmen.clear();
    final userSnap =
        await FirebaseFirestore.instance
            .collection('users')
            .where('role', isEqualTo: 'craftsman')
            .where('is_accepted', isEqualTo: 1)
            .get();
    for (var userDoc in userSnap.docs) {
      final uid = userDoc.id;
      final craftsmanDoc =
          await FirebaseFirestore.instance
              .collection('craftsmen')
              .doc(uid)
              .get();
      if (!craftsmanDoc.exists) {
        continue;
      }
      if (!craftsmanDoc['Speciality'].toString().contains(category)) {
        continue;
      }

      craftsmen.add({
        'id': craftsmanDoc.id,
        'username': userDoc['username'],
        'ImageURL': userDoc['ImageURL'],
        'phonenumber': userDoc['phonenumber'],
        'city': userDoc['city'],
        'email': userDoc['email'],
        'Speciality': craftsmanDoc['Speciality'],
        'Description': craftsmanDoc['Description'],
      });
    }

    if (craftsmen.isEmpty) {
      Get.snackbar('Error', 'No craftsman found.');
    }

    return userSnap.docs;
  }

  Future<void> getOneCraftsman(String id) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    DocumentSnapshot userDoc =
        await firestore.collection('users').doc(id).get();
    DocumentSnapshot craftsmanRecord =
        await firestore.collection('craftsmen').doc(userDoc.id).get();
    if (craftsmanRecord.exists) {
      final craftsman = craftsmanRecord.data() as Map<String, dynamic>;
      final favorite =
          await FirebaseFirestore.instance
              .collection('customer')
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .collection('favorites')
              .doc(id)
              .get();
      pickedCraftsman = {
        'is_favorite': favorite.exists ? '1' : '0',
        'username': userDoc['username'],
        'id': craftsmanRecord.id,
        'ImageURL': userDoc['ImageURL'],
        'phonenumber': userDoc['phonenumber'],
        'city': userDoc['city'],
        'email': userDoc['email'],
        'Speciality': craftsman['Speciality'],
        'Description': craftsman['Description'],
        'from': craftsman['from'] ?? 'N/A',
        'to': craftsman['to'] ?? 'N/A',
      };
      pickedCraftsmanWorkDays = List<String>.from(craftsman['days'] ?? []);
      craftsmanWorkDays = pickedCraftsmanWorkDays;
      // Define your custom order
      final customOrder = ['Sat', 'Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri'];
      // Sort using the custom order
      pickedCraftsmanWorkDays.sort((a, b) {
        final aIndex = customOrder.indexOf(a);
        final bIndex = customOrder.indexOf(b);
        return aIndex.compareTo(bIndex);
      });
      String today = getDay();
      final index = customOrder.indexOf(today);
      final List<String> result =
          index != -1
              ? customOrder.sublist(index)
              : []; // fallback if value not found
      pickedCraftsmanWorkDays =
          pickedCraftsmanWorkDays.where((d) => result.contains(d)).toList();
    }
  }

  String getDay() {
    final now = DateTime.now();
    late int weekdayIndex;
    // final weekdays = ['Sat', 'Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri'];
    String weekday;
    final today = now.weekday;
    const customWeekdays = [
      'Sat', // 1
      'Sun', // 2
      'Mon', // 3
      'Tue', // 4
      'Wed', // 5
      'Thu', // 6
      'Fri', // 7
    ];
    final indexMap = {
      1: 2, // Monday → 2 (custom index)
      2: 3, // Tuesday → 3
      3: 4,
      4: 5,
      5: 6,
      6: 0, // Saturday → 0
      7: 1, // Sunday → 1
    };
    weekdayIndex = indexMap[today]!;
    weekday = customWeekdays[weekdayIndex];
    return weekday;
  }

  Future<void> addAppointment(
    String day,
    String description,
    XFile image,
  ) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final FirebaseStorage storage = FirebaseStorage.instance;

    final uid = FirebaseAuth.instance.currentUser!.uid;

    // 1️⃣ Create a unique file path
    final fileName = DateTime.now().millisecondsSinceEpoch.toString();
    final storageRef = storage.ref().child('issue_pics/$uid/$fileName.jpg');

    // 2️⃣ Upload the file
    final uploadTask = storageRef.putFile(File(image.path));
    final snapshot = await uploadTask;

    // 3️⃣ Get the download URL
    final imageUrl = await snapshot.ref.getDownloadURL();

    // 4️⃣ Add appointment to Firestore with image URL
    await firestore.collection('appointments').add({
      'customer_id': uid,
      'craftsman_id': pickedCraftsman['id'],
      'reservation_day': day,
      'description': description,
      'image_url': imageUrl,
      'createdAt': FieldValue.serverTimestamp(),
      'completed': false,
    });

  }


  Future<void> createChat(String craftsmanID) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final chatID = '${uid}_$craftsmanID';

    final chatDoc = FirebaseFirestore.instance.collection('chat').doc(chatID);

    final docSnapshot = await chatDoc.get();
    if (!docSnapshot.exists) {
      await chatDoc.set({
        'customerID': uid,
        'craftsmanID': craftsmanID,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } else {
      Get.snackbar('Error', 'Chat already exists:');
    }
  }

  Future<void> loadCustomerProfileData({
    required TextEditingController nameController,
    required TextEditingController emailController,
    required TextEditingController phoneController,
    required TextEditingController cityController,
    required Rx<XFile?> imageRx,
  }) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();

    if (userDoc.exists) {
      final data = userDoc.data()!;
      nameController.text = data['username'] ?? '';
      emailController.text = data['email'] ?? '';
      phoneController.text = data['phonenumber'] ?? '';
      cityController.text = data['city'] ?? 'Amman';

      final imageUrl = data['ImageURL'];
      if (imageUrl != null && imageUrl != '') {
        // Download image to display it locally if needed (optional)
      }

      username.value = data['username'];
      email.value = data['email'];
      secPhoneNum.value = data['phonenumber'];
      gender.value = data['gender'];
      city.value = data['city'];
      imageURL.value = data['ImageURL'] ?? '';
    }
  }

  Future<void> saveCustomerProfile({
    required String name,
    required String email,
    required String phone,
    required String city,
    required Rx<XFile?> imageRx,
  }) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    String? imageUrl;

    if (imageRx.value != null) {
      String ext = p.extension(imageRx.value!.path).replaceFirst('.', '');
      final storageRef = FirebaseStorage.instance.ref().child(
        'profile_pictures/$uid.$ext',
      );
      await storageRef.putFile(File(imageRx.value!.path));
      imageUrl = await storageRef.getDownloadURL();
    }

    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'username': name,
      'email': email,
      'phonenumber': phone,
      'city': city,
      if (imageUrl != null) 'ImageURL': imageUrl,
    });

    username.value = name;
    this.email.value = email;
    secPhoneNum.value = phone;
    this.city.value = city;
    if (imageUrl != null) imageURL.value = imageUrl;
  }

  Future<void> toggleFavoriteCraftsman(String craftsmanId) async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final favDoc = FirebaseFirestore.instance
        .collection('customers')
        .doc(userId)
        .collection('favorites')
        .doc(craftsmanId);

    final docSnapshot = await favDoc.get();
    if (docSnapshot.exists) {
      await favDoc.delete();
      isCraftsmanFavorite.value = false;
    } else {
      await favDoc.set({'timestamp': FieldValue.serverTimestamp()});
      isCraftsmanFavorite.value = true;
    }
  }

  Future<void> checkIfFavorite(String craftsmanId) async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final favDoc =
        await FirebaseFirestore.instance
            .collection('customers')
            .doc(userId)
            .collection('favorites')
            .doc(craftsmanId)
            .get();

    isCraftsmanFavorite.value = favDoc.exists;
  }

  Future<void> fetchFavoriteCraftsmen() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;

      final favoritesSnapshot =
          await FirebaseFirestore.instance
              .collection('customers')
              .doc(userId)
              .collection('favorites')
              .get();

      List<Map<String, dynamic>> fetchedFavorites = [];

      for (var doc in favoritesSnapshot.docs) {
        final craftsmanId = doc.id;

        // Get craftsman document
        final craftsmanDoc =
            await FirebaseFirestore.instance
                .collection('craftsmen')
                .doc(craftsmanId)
                .get();

        // Get user document
        final userDoc =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(craftsmanId)
                .get();

        if (craftsmanDoc.exists && userDoc.exists) {
          final combinedData = {
            'id': craftsmanId,
            'username': userDoc['username'],
            'ImageURL': userDoc['ImageURL'],
            'email': userDoc['email'],
            'phonenumber': userDoc['phonenumber'],
            'city': userDoc['city'],
            'Speciality': craftsmanDoc['Speciality'],
            'rating':
                craftsmanDoc.data()?.containsKey('averageRating') == true
                    ? craftsmanDoc['averageRating']
                    : 0.0,
          };
          fetchedFavorites.add(combinedData);
        }
      }

      favoriteCraftsmen.assignAll(fetchedFavorites);
    } catch (e) {
      Get.snackbar('Error', 'Could not load favorites');
    }
  }

  Future<void> getCraftsmanReviews() async {
    String craftsmanId = pickedCraftsman['id']!;
    try {
      final snapshot =
          await FirebaseFirestore.instance
              .collection('craftsmen')
              .doc(craftsmanId)
              .collection('reviews')
              .orderBy('createdAt', descending: true)
              .get();

      // Convert each document to a Map
      final loadedReviews = <Map<String, dynamic>>[];

      for (final doc in snapshot.docs) {
        final data = doc.data();
        data['id'] = doc.id; // ✅ this is your customer_id

        // ✅ Now fetch the customer doc
        final customerDoc =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(data['customer_id'])
                .get();

        if (customerDoc.exists) {
          final customerData = customerDoc.data();
          data['username'] = customerData?['username'];
          data['ImageURL'] = customerData?['ImageURL'];
        }
        loadedReviews.add(data);
      }

      // ✅ Update the reactive list
      reviews.assignAll(loadedReviews);
    } catch (e) {
      Get.snackbar('Error', 'can not get the reviews');
    }
  }

  Future<void> addReview(double rating, String review) async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final craftsmanId = pickedCraftsman['id'];

    final craftsmanRef = FirebaseFirestore.instance
        .collection('craftsmen')
        .doc(craftsmanId);
    final reviewRef = craftsmanRef.collection('reviews').doc(userId);

    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        // Get craftsman aggregate data
        final craftsmanSnapshot = await transaction.get(craftsmanRef);
        final data = craftsmanSnapshot.data() ?? {};

        int totalReviews = (data['totalReviews'] ?? 0);
        double sumOfRatings = (data['sumOfRatings'] ?? 0.0);

        // Check if user already submitted a review
        final existingReviewSnapshot = await transaction.get(reviewRef);
        bool isNewReview = !existingReviewSnapshot.exists;
        double? previousRating =
            isNewReview
                ? null
                : (existingReviewSnapshot.data()?['rating'] ?? 0.0);

        // Calculate new aggregate values
        if (isNewReview) {
          totalReviews += 1;
          sumOfRatings += rating;
        } else {
          sumOfRatings = sumOfRatings - previousRating! + rating;
        }

        final averageRating = sumOfRatings / totalReviews;

        // Update the review
        transaction.set(reviewRef, {
          'review': review,
          'rating': rating,
          'customer_id': userId,
          'createdAt': FieldValue.serverTimestamp(),
        });

        // Update aggregate data
        transaction.update(craftsmanRef, {
          'totalReviews': totalReviews,
          'sumOfRatings': sumOfRatings,
          'averageRating': averageRating,
        });
      });

      // Optionally: update local state
      reviews.add({
        'review': review,
        'rating': rating,
        'username': username.value,
        'ImageURL': imageURL.value,
        'customer_id': userId,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      reviews.removeLast();
      reviews.refresh();
      Get.snackbar('Error', 'Could not save review. Please try again.');
    }
  }
}
