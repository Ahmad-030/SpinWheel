import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../Models/Spin_Entry.dart';

class SpinReel extends StatelessWidget {
  final SpinEntry entry;

  const SpinReel({Key? key, required this.entry}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(int.parse(entry.gradientStart.replaceAll('#', '0xFF'))),
            Color(int.parse(entry.gradientEnd.replaceAll('#', '0xFF'))),
          ],
        ),
      ),
      child: Center(
        child: entry.type == 'text'
            ? Text(
          entry.value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        )
            : const Icon(
          Icons.image,
          size: 80,
          color: Colors.white,
        ),
      ),
    );
  }
}