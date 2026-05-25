import 'package:flutter/material.dart';

class NumberPad extends StatelessWidget {
  final Function(int) onNumberPressed;

  const NumberPad({super.key, required this.onNumberPressed});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 9,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 2.0, // Membuat tombol lebih persegi panjang seperti mockup
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemBuilder: (context, index) {
        int number = index + 1;
        return InkWell(
          onTap: () => onNumberPressed(number),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF232334),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF3A3A5A), width: 0.5),
            ),
            child: Center(
              child: Text(
                number.toString(),
                style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w500),
              ),
            ),
          ),
        );
      },
    );
  }
}