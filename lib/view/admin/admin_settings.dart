import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';

class AdminSettings extends StatefulWidget {
  const AdminSettings({super.key});

  @override
  State<AdminSettings> createState() => _AdminSettingsState();
}

class _AdminSettingsState extends State<AdminSettings> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _arabicNameController = TextEditingController();
  final TextEditingController _englishNameController = TextEditingController();

  XFile? _pickedImage;
  bool _isSubmitting = false;

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image =
    await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);

    if (image != null) {
      setState(() {
        _pickedImage = image;
      });
    }
  }

  /// Upload image to Firebase Storage and return download URL
  Future<String> _uploadImageToStorage(File imageFile) async {
    final storageRef = FirebaseStorage.instance.ref();
    final fileName =
        'profession_${DateTime.now().millisecondsSinceEpoch.toString()}.png';
    final imageRef = storageRef.child('profession_images/$fileName');

    final uploadTask = await imageRef.putFile(imageFile);
    final downloadUrl = await uploadTask.ref.getDownloadURL();
    return downloadUrl;
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (_pickedImage == null) {
      Get.showSnackbar(
        const GetSnackBar(
          message: 'Please select an image',
          snackPosition: SnackPosition.BOTTOM,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final arabicName = _arabicNameController.text.trim();
      final englishName = _englishNameController.text.trim();

      // 1) Upload image
      final file = File(_pickedImage!.path);
      final pictureUrl = await _uploadImageToStorage(file);

      // 2) Save to Firestore
      await FirebaseFirestore.instance.collection('profession').add({
        'arabic_name': arabicName,
        'english_name': englishName,
        'picture_url': pictureUrl,
        'created_at': FieldValue.serverTimestamp(),
      });

      Get.showSnackbar(
        const GetSnackBar(
          message: 'Profession saved successfully ✅',
          snackPosition: SnackPosition.BOTTOM,
          duration: Duration(seconds: 2),
        ),
      );

      _arabicNameController.clear();
      _englishNameController.clear();
      setState(() {
        _pickedImage = null;
      });
    } catch (e) {
      Get.showSnackbar(
        GetSnackBar(
          message: 'Error: $e',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _arabicNameController.dispose();
    _englishNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Panel"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: Text(
                      "Add a Craftsman Category",
                      style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Arabic name
                  TextFormField(
                    controller: _arabicNameController,
                    decoration: const InputDecoration(
                      labelText: "Arabic Name",
                      hintText: "اكتب اسم الفئة بالعربي",
                      border: OutlineInputBorder(),
                    ),
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.right,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Please enter the Arabic name";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // English name
                  TextFormField(
                    controller: _englishNameController,
                    decoration: const InputDecoration(
                      labelText: "English Name",
                      hintText: "Enter category name in English",
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Please enter the English name";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Image picker
                  Text(
                    "Category Image",
                    style: TextStyle(
                        fontSize: 14, color: Colors.grey.shade800),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: _isSubmitting ? null : _pickImage,
                    child: Container(
                      height: 150,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: _pickedImage == null
                          ? const Center(
                        child: Text(
                          "Tap to upload image",
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                          : ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          File(_pickedImage!.path),
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Submit button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitForm,
                      child: _isSubmitting
                          ? const SizedBox(
                        height: 20,
                        width: 20,
                        child:
                        CircularProgressIndicator(strokeWidth: 2),
                      )
                          : const Text("Add Category"),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Existing professions list
            const Text(
              "Existing Professions",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('profession')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.only(top: 16.0),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (snapshot.hasError) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Text('Error: ${snapshot.error}'),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.only(top: 16.0),
                    child: Text(
                      "No professions added yet.",
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                final docs = snapshot.data!.docs;

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data =
                    docs[index].data() as Map<String, dynamic>;
                    final arabicName =
                        data['arabic_name']?.toString() ?? '';
                    final englishName =
                        data['english_name']?.toString() ?? '';
                    final pictureUrl =
                        data['picture_url']?.toString() ?? '';

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: ListTile(
                        leading: pictureUrl.isNotEmpty
                            ? CircleAvatar(
                          backgroundImage: NetworkImage(pictureUrl),
                        )
                            : const CircleAvatar(
                          child: Icon(Icons.work),
                        ),
                        title: Text(englishName),
                        subtitle: Text(
                          arabicName,
                          textDirection: TextDirection.rtl,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
