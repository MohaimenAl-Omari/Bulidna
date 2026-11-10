import 'package:buildna/components/custom_clickable_image.dart';
import 'package:buildna/controller/auth_controller.dart';
import 'package:buildna/controller/craftsman_controller.dart';
import 'package:buildna/view/craftsman/chat.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timeago/timeago.dart' as timeago;

class CraftsmanChatList extends StatelessWidget {
  final AuthController authController = Get.find<AuthController>();

  final RxString searchQuery = ''.obs;
  final TextEditingController searchController = TextEditingController();

  CraftsmanChatList({super.key});

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
          elevation: 0.5,
          centerTitle: true,
          title: const Text(
            'Messages 💬',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 22,
              color: Colors.black,
            ),
          ),
          iconTheme: const IconThemeData(color: Colors.black),
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
                    hintText: 'Search your customer...'.tr,
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

              // StreamBuilder for chats
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream:
                      FirebaseFirestore.instance
                          .collection('chat')
                          .where(
                            'craftsmanID',
                            isEqualTo: FirebaseAuth.instance.currentUser!.uid,
                          )
                          .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(child: Text('No chats yet.'));
                    }
                    final chats = snapshot.data!.docs;

                    return ListView.builder(
                      padding: EdgeInsets.symmetric(
                        horizontal: width * 0.03,
                        vertical: height * 0.02,
                      ),
                      itemCount: chats.length,
                      itemBuilder: (context, index) {
                        final chat = chats[index];
                        final customerID = chat['customerID'];
                        final lastMessage = chat['lastMessage'] ?? '';
                        final lastMessageTime =
                            (chat['lastMessageTime'] as Timestamp?)?.toDate();

                        return FutureBuilder<DocumentSnapshot>(
                          future:
                              FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(customerID)
                                  .get(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.grey,
                                ),
                                title: Text('Loading...'),
                              );
                            }
                            if (!snapshot.hasData || !snapshot.data!.exists) {
                              return const ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.grey,
                                ),
                                title: Text('User not found'),
                              );
                            }

                            final customer = snapshot.data!;
                            final imageURL = customer['ImageURL'] ?? '';
                            final name = customer['username'] ?? '';

                            return Obx(() {
                              // Filter by search query
                              if (!name.toLowerCase().contains(
                                searchQuery.value,
                              )) {
                                return const SizedBox.shrink();
                              }

                              return InkWell(
                                onTap: () async {
                                  await (authController.user
                                          as CraftsmanController)
                                      .getOneCustomer(customerID);
                                  Get.to(
                                    () => Chat(
                                      customer:
                                          (authController.user
                                                  as CraftsmanController)
                                              .pickedCustomer,
                                    ),
                                  );
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
                                          color: Colors.grey[200],
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
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
