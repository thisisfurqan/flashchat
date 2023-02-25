import 'package:flutter/material.dart';

class Materialbutton extends StatelessWidget {
  final Color color;
  final String buttonText;
  final Function onPressed;

  Materialbutton({
    required this.color,
    required this.buttonText,
    required this.onPressed,
  });
  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 5.0,
      color: color,
      borderRadius: BorderRadius.circular(30.0),
      child: MaterialButton(
        onPressed: onPressed as VoidCallback,
        minWidth: 200.0,
        height: 42.0,
        child: Text(buttonText, style: TextStyle(
          color: Colors.white,
        ),),
      ),
    );
  }
}
