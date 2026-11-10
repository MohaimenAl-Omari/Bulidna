import 'package:flutter/material.dart';

// ignore: must_be_immutable
class CircularCountdown extends StatefulWidget {
  int seconds;
  final VoidCallback? onButtonPressed;

  CircularCountdown({super.key, required this.seconds, this.onButtonPressed});

  @override
  State<CircularCountdown> createState() => _CircularCountdownState();
}

class _CircularCountdownState extends State<CircularCountdown> {
  bool showButton = false;

  @override
  Widget build(BuildContext context) {
    double circleSize = MediaQuery.of(context).size.width / 4;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showButton)
          TextButton(
            onPressed: () {
              setState(() {
                widget.seconds = 60;
                showButton = !showButton;
                if (widget.onButtonPressed != null) {
                  widget
                      .onButtonPressed!(); // e.g., resendOTP() in your controller
                } else {}
              });
            },
            child: const Text(
              'Resend OTP',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          )
        else
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 1, end: 0),
            duration: Duration(seconds: widget.seconds),
            onEnd: () {
              setState(() {
                showButton = true;
              });
            },
            builder: (context, value, child) {
              return SizedBox(
                width: circleSize,
                height: circleSize,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: value,
                      strokeWidth: 2,
                      backgroundColor: Colors.grey[300],
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Colors.black,
                      ),
                    ),
                    Text(
                      '${(value * widget.seconds).ceil()}s',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }
}
