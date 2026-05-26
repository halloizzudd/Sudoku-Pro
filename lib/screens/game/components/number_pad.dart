import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';

class NumberPad extends StatelessWidget {
  final Function(int) onNumberPressed;

  const NumberPad({super.key, required this.onNumberPressed});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
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
              color: c.surface2,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: c.gridLine, width: 0.5),
            ),
            child: Center(
              child: Text(
                number.toString(),
                style: TextStyle(
                    color: c.primary,
                    fontSize: 24,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ),
        );
      },
    );
  }
}