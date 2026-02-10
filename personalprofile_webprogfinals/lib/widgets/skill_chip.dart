import 'package:flutter/material.dart';

class SkillChip extends StatelessWidget {
  final String label;

  const SkillChip({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label),
      backgroundColor: Colors.red.withOpacity(.2),
      labelStyle: const TextStyle(color: Colors.redAccent),
      side: const BorderSide(color: Colors.redAccent),
    );
  }
}
