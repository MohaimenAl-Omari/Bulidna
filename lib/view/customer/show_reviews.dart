import 'package:buildna/components/custom_button.dart';
import 'package:buildna/components/custom_text_field.dart';
import 'package:buildna/controller/auth_controller.dart';
import 'package:buildna/controller/craftsman_controller.dart';
import 'package:buildna/controller/customer_controller.dart';
import 'package:buildna/controller/loader_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';

class ShowReviews extends StatelessWidget {
  ShowReviews({super.key});

  final AuthController authController = Get.find<AuthController>();
  final CraftsmanController craftsmanController = Get.put(
    CraftsmanController(),
  );

  final String craftsmanId = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(centerTitle: true, title: const Text('Reviews')),
      body: Column(
        children: [
          Expanded(
            child: Obx(
              () =>
                  (authController.user as CustomerController).reviews.isEmpty
                      ? const Center(child: Text('No reviews found'))
                      : ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        itemCount:
                            (authController.user as CustomerController)
                                .reviews
                                .length,
                        itemBuilder: (context, index) {
                          final review =
                              (authController.user as CustomerController)
                                  .reviews[index];
                          return Container(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade300),
                              boxShadow: [
                                BoxShadow(
                                  // ignore: deprecated_member_use
                                  color: Colors.black.withOpacity(0.03),
                                  blurRadius: 3,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CircleAvatar(
                                      radius: 20,
                                      backgroundImage:
                                          review['ImageURL'] != null &&
                                                  review['ImageURL'] != ''
                                              ? NetworkImage(review['ImageURL'])
                                              : const AssetImage(
                                                    'assets/images/default_profile.png',
                                                  )
                                                  as ImageProvider,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            review['username'],
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    RatingBarIndicator(
                                      rating: review['rating'] * 1.0,
                                      itemBuilder:
                                          (context, _) => const Icon(
                                            Icons.star,
                                            color: Colors.amber,
                                          ),
                                      itemCount: 5,
                                      itemSize: 18,
                                      direction: Axis.horizontal,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  review['review'],
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
            ),
          ),
          SizedBox(height: height / 60),
          CustomButton(
            onPressed: () {
              LoaderController loader = Get.find<LoaderController>();
              addReview(context);
              loader.hide();
            },
            text: 'Add a review',
            height: height / 30,
            width: width / 2,
          ),
          SizedBox(height: height / 30),
        ],
      ),
    );
  }

  Future<Widget?> addReview(BuildContext context) {
    double rating = 0.0;
    TextEditingController reviewController = TextEditingController();

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        double width = MediaQuery.of(context).size.width;
        return AlertDialog(
          scrollable: true,
          title: const Column(
            children: [
              Center(
                child: Text(
                  '🛠️ Add your review 🔨',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
              Divider(color: Colors.black, thickness: 2),
            ],
          ),
          content: SizedBox(
            width: width * 0.9,
            child: Column(
              children: [
                CustomTextField(
                  hint: 'Write about your experience here..',
                  label: '',
                  maxLines: 6,
                  textController: reviewController,
                ),
                RatingBar.builder(
                  minRating: 1,
                  itemBuilder:
                      (context, _) =>
                          const Icon(Icons.star_rate, color: Colors.amber),
                  onRatingUpdate: (value) => rating = value,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await (authController.user as CustomerController).addReview(
                  rating,
                  reviewController.text.trim(),
                );
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
