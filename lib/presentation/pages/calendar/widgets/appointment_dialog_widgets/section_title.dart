import 'package:flutter/material.dart';

class SectionTitle extends StatelessWidget {
  final String number;
  final String title;
  final bool isActive;
  final bool isRequired;

  const SectionTitle({
    super.key,
    required this.number,
    required this.title,
    required this.isActive,
    this.isRequired = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          "$number. $title",
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: isActive ? Theme.of(context).primaryColor : Colors.grey,
          ),
        ),
        if (isRequired) const Text(" *", style: TextStyle(color: Colors.red)),
      ],
    );
  }
}
