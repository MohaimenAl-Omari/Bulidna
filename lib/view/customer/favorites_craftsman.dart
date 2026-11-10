import 'package:buildna/controller/auth_controller.dart';
import 'package:buildna/controller/customer_controller.dart';
import 'package:buildna/view/customer/craftsman_details.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FavoritesCraftsman extends StatelessWidget {
  final AuthController authController = Get.find<AuthController>();
  final CustomerController customerController = Get.find<CustomerController>();

  FavoritesCraftsman({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    customerController.fetchFavoriteCraftsmen();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Favorites'.tr,
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back_ios),
        ),
      ),
      body: Obx(() {
        final favorites = customerController.favoriteCraftsmen;
        if (favorites.isEmpty) {
          return Center(child: Text('No favorite craftsmen yet.'.tr));
        }

        return SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: height / 10),
              Container(
                width: width,
                height: height * 0.8,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(80),
                  ),
                  boxShadow: [
                    BoxShadow(
                      // ignore: deprecated_member_use
                      color: Colors.black.withOpacity(0.2),
                      offset: const Offset(0, -10),
                      blurRadius: 40,
                      spreadRadius: 30,
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.topCenter,
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      top: -40,
                      child: Obx(() {
                        final user = authController.user;
                        return CircleAvatar(
                          radius: 50,
                          backgroundImage:
                              user.imageURL.value.isNotEmpty
                                  ? NetworkImage(user.imageURL.value)
                                  : const AssetImage(
                                        'assets/default_avatar.png',
                                      )
                                      as ImageProvider,
                        );
                      }),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        top: 80,
                        left: width / 15,
                        right: width / 15,
                      ),
                      child: ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: favorites.length,
                        itemBuilder: (context, index) {
                          final craftsman = favorites[index];

                          return Card(
                            color: Colors.white,
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            margin: EdgeInsets.only(bottom: height * 0.025),
                            child: Container(
                              height: height * 0.22,
                              padding: const EdgeInsets.all(12),
                              child: Stack(
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image.network(
                                          craftsman['ImageURL'] ??
                                              'https://via.placeholder.com/150',
                                          width: width * 0.3,
                                          height: double.infinity,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      SizedBox(width: width * 0.04),
                                      Expanded(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              craftsman['username'] ??
                                                  'No Name',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              craftsman['Speciality'] ??
                                                  'No Profession',
                                              style: const TextStyle(
                                                color: Colors.black,
                                              ),
                                            ),
                                            SizedBox(height: height / 20),
                                            ElevatedButton(
                                              onPressed: () {
                                                final userId =
                                                    craftsman['userID'];
                                                if (userId != null &&
                                                    userId is String &&
                                                    userId.isNotEmpty) {
                                                  customerController
                                                      .getOneCraftsman(userId)
                                                      .then((_) {
                                                        Get.to(
                                                          () =>
                                                              CraftsmanDetails(),
                                                        );
                                                      });
                                                } else {
                                                  Get.snackbar(
                                                    'Error',
                                                    'Craftsman ID is not found.',
                                                    snackPosition:
                                                        SnackPosition.TOP,
                                                    backgroundColor: Colors.red,
                                                    colorText: Colors.white,
                                                  );
                                                }
                                              },

                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.black,
                                                foregroundColor: Colors.white,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                              ),
                                              child: Text('Book'.tr),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),

                                  // Favorite heart in top right
                                  const Positioned(
                                    top: 35,
                                    right: 4,
                                    child: Icon(
                                      Icons.favorite,
                                      color: Colors.red,
                                      size: 23,
                                    ),
                                  ),
                                  // Star rating bottom right
                                  Positioned(
                                    bottom: 20,
                                    right: 4,
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.star,
                                          color: Colors.amber,
                                          size: 18,
                                        ),
                                        Text(craftsman['rating'].toString()),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
