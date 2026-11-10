import 'package:buildna/controller/auth_controller.dart';
import 'package:buildna/controller/craftsman_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  final AuthController authController = Get.find<AuthController>();
  final List<String> days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  Set<String> selectedDays = {};
  TimeOfDay? fromTime;
  TimeOfDay? toTime;

  Future<void> pickTime(bool isFrom, BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      final rounded = TimeOfDay(hour: picked.hour, minute: 0);
      setState(() {
        if (isFrom) {
          fromTime = rounded;
        } else {
          toTime = rounded;
        }
      });
    }
  }

  void verifySchedule() async {
    if (selectedDays.isEmpty || fromTime == null || toTime == null) {
      Get.snackbar(
        colorText: Colors.black,
        'Error',
        'Select at least one day with both times!',
        snackPosition: SnackPosition.TOP,
      );
    } else {
      String fromTimeString = fromTime!.format(context);
      String toTimeString = toTime!.format(context);
      await (authController.user as CraftsmanController).addSchedule(
        fromTimeString,
        toTimeString,
        selectedDays.toList(),
      );
    }
  }

  void toggleDay(String day) {
    setState(() {
      if (selectedDays.contains(day)) {
        selectedDays.remove(day);
      } else {
        selectedDays.add(day);
      }
    });
  }

  TimeOfDay? parseTimeOfDay(String? timeString) {
    if (timeString == null) return null;

    // Clean ALL whitespace, weird spaces, and trim
    timeString =
        timeString
            .replaceAll(RegExp(r'\s+'), ' ') // normalize multiple spaces
            .replaceAll('\u202F', ' ')
            .replaceAll('\u00A0', ' ')
            .trim();

    if (timeString.isEmpty) return null;
    final DateFormat format = DateFormat.jm();
    return TimeOfDay.fromDateTime(format.parseLoose(timeString));
  }

  @override
  void initState() {
    CraftsmanController craftsmanController =
        (authController.user) as CraftsmanController;
    if (craftsmanController.from.value.isNotEmpty) {
      setState(() {
        fromTime =
            parseTimeOfDay(craftsmanController.from.value.trim()) ??
            TimeOfDay.now();
        toTime =
            parseTimeOfDay(craftsmanController.to.value.trim()) ??
            TimeOfDay.now();
        selectedDays = craftsmanController.selectedDays.toSet();
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final screenWidth = mq.size.width;
    final screenHeight = mq.size.height;

    final horizontalPadding = screenWidth * 0.05;
    final verticalSpacing = screenHeight * 0.03;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Create Schedule'.tr,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 22),
        ),
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: const Icon(Icons.arrow_back_ios),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: verticalSpacing),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Select Days',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            SizedBox(height: verticalSpacing * 0.5),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children:
                  days.map((day) {
                    final bool isSelected = selectedDays.contains(day);
                    return OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        backgroundColor:
                            isSelected ? Colors.black : Colors.white,
                        foregroundColor:
                            isSelected ? Colors.white : Colors.black,
                        side: const BorderSide(color: Colors.black),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 14,
                        ),
                      ),
                      onPressed: () => toggleDay(day),
                      child: Text(day, style: const TextStyle(fontSize: 16)),
                    );
                  }).toList(),
            ),
            SizedBox(height: verticalSpacing * 1.5),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Select Time Range',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            SizedBox(height: verticalSpacing * 0.5),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => pickTime(true, context),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.black),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      fromTime != null
                          ? 'From: ${fromTime!.format(context)}'
                          : 'From.tr',
                      style: const TextStyle(color: Colors.black, fontSize: 16),
                    ),
                  ),
                ),
                SizedBox(width: screenWidth * 0.05),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => pickTime(false, context),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.black),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      toTime != null ? 'To: ${toTime!.format(context)}' : 'To',
                      style: const TextStyle(color: Colors.black, fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: verifySchedule,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Verify My Schedule'.tr,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
            SizedBox(height: verticalSpacing),
          ],
        ),
      ),
    );
  }
}
