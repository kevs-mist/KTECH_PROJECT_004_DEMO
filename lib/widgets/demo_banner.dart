import 'package:flutter/material.dart';

class DemoBanner extends StatelessWidget {
  const DemoBanner({
    super.key,
    this.message = "Demo mode — sample data only. Changes won't be saved.",
  });
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: const BoxDecoration(
        color: Color(0xFFFFF3CD),
        border: Border(bottom: BorderSide(color: Color(0xFFFFE69C))),
      ),
      child: Row(
        children: [
          const Icon(Icons.science_outlined, size: 18, color: Color(0xFF664D03)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Color(0xFF664D03),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DemoChip extends StatelessWidget {
  const DemoChip({super.key});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF3CD),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Text(
          'DEMO',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: Color(0xFF664D03),
          ),
        ),
      );
}
