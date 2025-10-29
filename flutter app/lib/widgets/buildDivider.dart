import 'package:flutter/material.dart';
Widget buildDivider() {
    return Row(
      children: [
        Expanded(child: Container(height: 1, color: Colors.black)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'OR',
            style: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Expanded(child: Container(height: 1, color: Colors.black)),
      ],
    );
  }