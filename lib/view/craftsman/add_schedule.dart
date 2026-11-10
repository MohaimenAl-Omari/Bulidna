import 'package:buildna/components/custom_button.dart';
import 'package:buildna/components/custom_text_field.dart';
import 'package:buildna/view/craftsman/add_time_date.dart';
import 'package:buildna/view/craftsman/schedule_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Addschedule extends StatefulWidget {
  const Addschedule({super.key});

  @override
  State<StatefulWidget> createState() => _MakeSchedulePageState();
}

class _MakeSchedulePageState extends State<Addschedule> {
  // final AuthController authController = Get.find<AuthController>();
  final TextEditingController detailsController = TextEditingController();
  List<String> workingHours = [];
  List<String> workingDays = [];

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Make my schedule',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 22),
        ),
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back_ios),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start, // Align top of image and text
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  // child: ClickableImage(
                  //   // imagePath: authController.user.imageURL.value,
                  //   width: width / 2.6,
                  //   height: height / 6,
                  // ),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Text(
                    //   // authController.user.username.value,
                    //   style: const TextStyle(
                    //     fontWeight: FontWeight.bold,
                    //     fontSize: 18,
                    //   ),
                    // ),
                    // Text(
                    //   (authController.user as CraftsmanController)
                    //       .speciality
                    //       .value,
                    //   style: const TextStyle(fontSize: 14, color: Colors.black),
                    // ),
                  ],
                ),
              ],
            ),
            SizedBox(height: height / 25),

            // Details dection
            CustomTextField(
              hint: 'Write here...',
              label: 'Details',
              textController: detailsController,
              maxLines: 6,
            ),

            SizedBox(height: height / 23),

            // Working Hours
            _buildSectionTitle('Working Hours', () {
              Get.to(() => const SchedulePage());
            }),
            SizedBox(height: height / 80),
            _buildAddRow(width),

            const SizedBox(height: 24),

            // Working Days
            _buildSectionTitle('Working Day', () => {}),
            SizedBox(height: height / 80),
            _buildAddRow(width),

            const Spacer(),

            CustomButton(
              height: 16,
              onPressed: () async {
                final result = await Get.to(() => const TimeAndDayScreen());
                if (result != null) {
                  setState(() {
                    // Add selected days
                    List<String> days = List<String>.from(result['days']);
                    workingDays.addAll(days);

                    // Add all selected time ranges
                    result['timeRanges'].forEach((range) {
                      workingHours.add('${range['from']} - ${range['to']}');
                    });
                  });
                }
              },

              text: 'Add',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, VoidCallback onSeeAllTap) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        GestureDetector(
          onTap: onSeeAllTap,
          child: const Text(
            'See All',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  Widget _buildAddRow(double width) {
    List<Widget> items = [];
    for (int i = 0; i < 2; i++) {
      if (i < workingDays.length && i < workingHours.length) {
        items.add(
          Container(
            width: (width - 60) / 3,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFEFEFEF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                '${workingDays[i]}\n${workingHours[i]}',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ),
        );
      } else {
        items.add(
          Container(
            width: (width - 60) / 3,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFEFEFEF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text('+', style: TextStyle(fontSize: 24)),
            ),
          ),
        );
      }
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: items,
    );
  }
}
