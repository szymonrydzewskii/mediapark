import 'package:flutter/material.dart';

class KonsultacjeBox extends StatelessWidget {
  const KonsultacjeBox({super.key});

  @override
  Widget build(BuildContext context) {
    final boxScreenWidth = (MediaQuery.of(context).size.width) * 0.45;
    final boxScreenHeight = (MediaQuery.of(context).size.height) * 0.20;

    return Padding(
      padding: const EdgeInsets.all(10),
      child: Container(
        width: boxScreenWidth,
        height: boxScreenHeight,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Color(0xff1f005c),
              Color(0xff5b0060),
              Color(0xff870160),
              Color(0xffac255e),
              Color(0xffca485c),
              Color(0xffe16b5c),
              Color(0xfff39060),
              Color(0xffffb56b),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text(
          'KONSULTACJE',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
