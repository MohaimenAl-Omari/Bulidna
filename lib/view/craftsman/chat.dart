import 'package:buildna/components/custom_clickable_image.dart';
import 'package:buildna/controller/auth_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Chat extends StatelessWidget {
  final AuthController authController = Get.find<AuthController>();
  final TextEditingController messageController = TextEditingController();

  Chat({super.key, required this.customer});
  final Map<String, dynamic> customer;
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    final String craftsmanID = FirebaseAuth.instance.currentUser!.uid;
    final String customerID = customer['customer_id'];
    final String chatID = '${customerID}_$craftsmanID';
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  ClipOval(
                    child: ClickableImage(
                      imagePath: customer['image_url']!,
                      width: height * 0.06,
                      height: height * 0.06,
                    ),
                  ),
                  SizedBox(width: width * 0.02),
                  Text(
                    customer['username']!.split(' ')[0],
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 22,
                    ),
                  ),
                ],
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.call_outlined),
              ),
            ],
          ),
          leading: IconButton(
            onPressed: () {
              Get.back();
            },
            icon: const Icon(Icons.arrow_back_ios),
          ),
        ),

        // ✅ MESSAGES BODY
        body: Column(
          children: [
            StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance
                      .collection('chat')
                      .doc(chatID)
                      .collection('messages')
                      .orderBy('createdAt', descending: true)
                      .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data?.docs ?? [];

                return Expanded(
                  child: ListView.builder(
                    reverse: true,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final msg = messages[index];
                      final isSender = msg['senderID'] == craftsmanID;
                      final messageText = msg['text'] ?? '';
                      return Column(
                        children: [
                          SizedBox(height: height * 0.005),
                          Align(
                            alignment:
                                isSender
                                    ? Alignment.centerRight
                                    : Alignment.centerLeft,
                            child:
                                isSender
                                    ? Container(
                                      margin: const EdgeInsets.symmetric(
                                        vertical: 4,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 15,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF545454),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        messageText,
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                    )
                                    : Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisSize:
                                          MainAxisSize
                                              .min, // ✅ SHRINK ROW TO CONTENT
                                      children: [
                                        ClipOval(
                                          child: ClickableImage(
                                            imagePath: customer['image_url']!,
                                            width: height * 0.05,
                                            height: height * 0.05,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Flexible(
                                          child: Container(
                                            margin: const EdgeInsets.symmetric(
                                              vertical: 4,
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 14,
                                              vertical: 15,
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFD9D9D9),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              messageText,
                                              style: const TextStyle(
                                                color: Colors.black,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                          ),
                        ],
                      );
                    },
                  ),
                );
              },
            ),
            Container(
              width: double.infinity,
              height: height / 10,
              padding: EdgeInsets.symmetric(horizontal: width * 0.05),
              color: Colors.black87,
              child: Row(
                children: [
                  // Rounded input container
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: messageController,
                              decoration: InputDecoration(
                                hintText: 'Write here'.tr,
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          Icon(Icons.camera_alt, color: Colors.grey[700]),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    onPressed: () async {
                      final message = messageController.text.trim();
                      if (message.isNotEmpty) {
                        await FirebaseFirestore.instance
                            .collection('chat')
                            .doc(chatID)
                            .collection('messages')
                            .add({
                              'senderID': craftsmanID,
                              'receiverID': customerID,
                              'text': message,
                              'createdAt': FieldValue.serverTimestamp(),
                            });
                        messageController.clear();
                      }
                    },
                    icon: const Icon(Icons.send, color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),

        // ✅ INPUT BAR
      ),
    );
  }
}
