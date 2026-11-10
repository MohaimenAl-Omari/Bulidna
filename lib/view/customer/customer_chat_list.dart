import 'package:buildna/components/custom_clickable_image.dart';
import 'package:buildna/controller/auth_controller.dart';
import 'package:buildna/controller/customer_controller.dart';
import 'package:buildna/view/customer/chat.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timeago/timeago.dart' as timeago;

class CustomerChatList extends StatelessWidget {
  final AuthController authController = Get.find<AuthController>();
  final RxString searchQuery = ''.obs;
  final TextEditingController searchController = TextEditingController();

  CustomerChatList({super.key});

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Align(
            alignment: Alignment.center,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: width * (0.03 + 0.01)),
              child: Text(
                'Messages 💬'.tr,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 26,
                ),
              ),
            ),
          ),
        ),
        body: Container(
          color: Colors.white,
          child: Column(
            children: [
              SizedBox(height: height / 60),

              // Search bar
              Padding(
                padding: EdgeInsets.symmetric(horizontal: width * 0.04),
                child: TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: 'Search Your Craftsman...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: (value) {
                    searchQuery.value = value.toLowerCase().trim();
                  },
                ),
              ),
              SizedBox(height: height * 0.015),

              StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance
                        .collection('chat')
                        .where(
                          'customerID',
                          isEqualTo: FirebaseAuth.instance.currentUser!.uid,
                        )
                        .orderBy('lastMessageTime', descending: true)
                        .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('No chats yet.'));
                  }

                  final chats = snapshot.data!.docs;

                  return Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.symmetric(
                        horizontal: width * 0.03,
                        vertical: height * 0.01,
                      ),
                      itemCount: chats.length,
                      itemBuilder: (context, index) {
                        final chat = chats[index];
                        final craftsmanID = chat['craftsmanID'];
                        final lastMessage = chat['lastMessage'] ?? '';
                        final lastMessageTime =
                            (chat['lastMessageTime'] as Timestamp?)?.toDate();

                        return FutureBuilder<DocumentSnapshot>(
                          future:
                              FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(craftsmanID)
                                  .get(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData || !snapshot.data!.exists) {
                              return const SizedBox();
                            }

                            final craftsman = snapshot.data!;
                            final name = craftsman['username'] ?? '';
                            final imageURL = craftsman['ImageURL'] ?? '';

                            // Obx used here to react to search
                            return Obx(() {
                              if (!name.toLowerCase().contains(
                                searchQuery.value,
                              )) {
                                return const SizedBox.shrink();
                              }

                              return InkWell(
                                onTap: () async {
                                  await (authController.user
                                          as CustomerController)
                                      .getOneCraftsman(craftsmanID);
                                  Get.to(() => Chat());
                                },
                                child: Container(
                                  height: height / 8,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: width * 0.02,
                                    vertical: height * 0.01,
                                  ),
                                  margin: EdgeInsets.only(
                                    bottom: height * 0.015,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    children: [
                                      ClipOval(
                                        child: Container(
                                          width: width * 0.15,
                                          height: width * 0.15,
                                          color:
                                              Colors
                                                  .grey[200], // fallback background
                                          child: ClickableImage(
                                            width: width * 0.15,
                                            height: width * 0.15,
                                            imagePath: imageURL,
                                          ),
                                        ),
                                      ),

                                      SizedBox(width: width * 0.04),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    name.split(' ')[0],
                                                    style: TextStyle(
                                                      fontSize: width * 0.04,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                Text(
                                                  lastMessageTime != null
                                                      ? timeago.format(
                                                        lastMessageTime,
                                                      )
                                                      : '',
                                                  style: TextStyle(
                                                    fontSize: width * 0.032,
                                                    color: Colors.grey[600],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: height * 0.005),
                                            Text(
                                              lastMessage,
                                              style: TextStyle(
                                                fontSize: width * 0.037,
                                                color: Colors.black87,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            });
                          },
                        );
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
