import 'package:flutter/material.dart';

class OgloszeniaBox extends StatelessWidget {
  const OgloszeniaBox({super.key});

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
              Color(0xffffb56b),
              Color(0xffca485c),
              Color(0xff870160),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text(
          'OGŁOSZENIA',
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
