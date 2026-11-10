import 'package:flutter/material.dart';
import 'package:buildna/components/custom_button.dart';
import 'package:get/get.dart';

class TimeAndDayScreen extends StatefulWidget {
  const TimeAndDayScreen({super.key});

  @override
  State<TimeAndDayScreen> createState() => _TimeAndDayScreenState();
}

class _TimeAndDayScreenState extends State<TimeAndDayScreen> {
  final List<String> days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
  List<String> selectedDays = [];
  TimeOfDay? fromTime;
  TimeOfDay? toTime;
  List<Map<String, String>> selectedTimeRanges = [];

  double screenWidth(BuildContext context) => MediaQuery.of(context).size.width;
  double screenHeight(BuildContext context) =>
      MediaQuery.of(context).size.height;

  Future<void> _selectFromTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: fromTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.black,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            dialogTheme: const DialogThemeData(backgroundColor: Colors.white),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => fromTime = TimeOfDay(hour: picked.hour, minute: 0));
    }
  }

  Future<void> _selectToTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: toTime ?? (fromTime ?? TimeOfDay.now()),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.black,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            dialogTheme: const DialogThemeData(backgroundColor: Colors.white),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => toTime = TimeOfDay(hour: picked.hour, minute: 0));
    }
  }

  Widget _buildDayChip(String day, BuildContext context) {
    final isSelected = selectedDays.contains(day);

    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            selectedDays.remove(day);
          } else {
            selectedDays.add(day);
          }
        });
      },
      child: Container(
        width: screenWidth(context) * 0.12,
        height: screenHeight(context) * 0.06,
        decoration: BoxDecoration(
          color: isSelected ? Colors.grey[200] : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.black : Colors.grey.shade400,
            width: 1.5,
          ),
        ),
        child: Center(
          child: Text(
            day,
            style: TextStyle(
              fontSize: screenWidth(context) * 0.035,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  Widget _timeButton(String label, TimeOfDay? time, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        padding: EdgeInsets.symmetric(vertical: screenHeight(context) * 0.02),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: Colors.grey.shade400, width: 1),
        ),
        elevation: 0,
      ),
      child: Text(
        time != null ? '$label: ${time.format(context)}' : label,
        style: TextStyle(
          fontSize: screenWidth(context) * 0.035,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sw = screenWidth(context);
    final sh = screenHeight(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Time and Day',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: sw * 0.045),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 24),
          onPressed: () => Get.back(),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: sw * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Day Section
            SizedBox(height: sh * 0.03),
            Text(
              'Day',
              style: TextStyle(
                fontSize: sw * 0.045,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: sh * 0.02),

            // First row of days (Sun-Thu)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children:
                  days
                      .sublist(0, 5)
                      .map((day) => _buildDayChip(day, context))
                      .toList(),
            ),
            SizedBox(height: sh * 0.015),

            // Second row of days (Fri-Sat)
            Row(
              children: [
                _buildDayChip(days[5], context),
                SizedBox(width: sw * 0.03),
                _buildDayChip(days[6], context),
              ],
            ),

            // Time Section
            SizedBox(height: sh * 0.04),
            Text(
              'Time Range',
              style: TextStyle(
                fontSize: sw * 0.045,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: sh * 0.02),

            // From/To buttons
            Row(
              children: [
                Expanded(
                  child: _timeButton(
                    'From',
                    fromTime,
                    () => _selectFromTime(context),
                  ),
                ),
                SizedBox(width: sw * 0.03),
                Expanded(
                  child: _timeButton(
                    'To',
                    toTime,
                    () => _selectToTime(context),
                  ),
                ),
              ],
            ),
            SizedBox(height: sh * 0.025),

            // Add Time Range button
            ElevatedButton.icon(
              onPressed: () {
                if (fromTime != null && toTime != null) {
                  final fromFormatted = fromTime!.format(context);
                  final toFormatted = toTime!.format(context);

                  final isValid =
                      fromTime!.hour < toTime!.hour ||
                      (fromTime!.hour == toTime!.hour &&
                          fromTime!.minute < toTime!.minute);

                  if (!isValid) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('From time must be before To time'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  setState(() {
                    selectedTimeRanges.add({
                      'from': fromFormatted,
                      'to': toFormatted,
                    });
                    fromTime = null;
                    toTime = null;
                  });
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please select both From and To times'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
              },
              icon: Icon(Icons.add, size: sw * 0.045),
              label: Text(
                'Add Time Range',
                style: TextStyle(fontSize: sw * 0.038),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  vertical: sh * 0.022,
                  horizontal: sw * 0.04,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: sh * 0.025),

            // Selected time ranges
            if (selectedTimeRanges.isNotEmpty) ...[
              Text(
                'Selected Time Ranges:',
                style: TextStyle(
                  fontSize: sw * 0.038,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: sh * 0.015),
            ],
            Wrap(
              spacing: sw * 0.03,
              runSpacing: sh * 0.015,
              children:
                  selectedTimeRanges.map((range) {
                    final label = '${range['from']} - ${range['to']}';
                    return Chip(
                      label: Text(
                        label,
                        style: TextStyle(fontSize: sw * 0.035),
                      ),
                      deleteIcon: Icon(Icons.close, size: sw * 0.04),
                      onDeleted:
                          () =>
                              setState(() => selectedTimeRanges.remove(range)),
                      backgroundColor: Colors.grey[200],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                    );
                  }).toList(),
            ),

            const Spacer(),

            // Final Add button
            Padding(
              padding: EdgeInsets.only(bottom: sh * 0.03),
              child: CustomButton(
                onPressed: () {
                  if (selectedTimeRanges.isNotEmpty &&
                      selectedDays.isNotEmpty) {
                    Navigator.pop(context, {
                      'days': selectedDays,
                      'timeRanges': selectedTimeRanges,
                    });
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Select at least one day and time'),
                      ),
                    );
                  }
                },
                text: 'Add',
                height: sh * 0.065,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
