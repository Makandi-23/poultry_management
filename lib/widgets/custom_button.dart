import 'package:flutter/material.dart';

class WelcomeButton extends StatefulWidget {
  const WelcomeButton({
    super.key,
    this.buttonText,
    this.onTap,
    this.color,
    this.textColor,
  });
  final String? buttonText;
  final Widget? onTap;
  final Color? color;
  final Color? textColor;

  @override
  _WelcomeButtonState createState() => _WelcomeButtonState();
}

class _WelcomeButtonState extends State<WelcomeButton> {
  double _scale = 1.0; // Initial scale of the button

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() {
          _scale = 0.9; // Scale down the button when tapped
        });
      },
      onTapUp: (_) {
        setState(() {
          _scale = 1.0; // Scale back up when the tap ends
        });
      },
      onTapCancel: () {
        setState(() {
          _scale = 1.0; // Reset scale if the tap is canceled
        });
      },
      onTap: () {
        // Navigate to the next screen when the button is tapped
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => widget.onTap!,
          ),
        );
      },
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut, // Smooth animation curve
        child: Container(
          padding: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            color: widget.color,
            borderRadius: BorderRadius.circular(30), // Circular shape
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
                spreadRadius: 4,
              ),
            ],
          ),
          child: Text(
            widget.buttonText!,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
              color: widget.textColor,
            ),
          ),
        ),
      ),
    );
  }
}
