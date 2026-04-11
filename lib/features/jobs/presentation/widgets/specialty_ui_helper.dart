import 'package:flutter/material.dart';

class SpecialtyUIHelper {
  static IconData getIcon(String specialty) {
    specialty = specialty.toLowerCase();
    if (specialty.contains('fontanero')) {
      return Icons.plumbing_rounded;
    } else if (specialty.contains('carpintero')) {
      return Icons.architecture_rounded;
    } else if (specialty.contains('electricista')) {
      return Icons.electrical_services_rounded;
    } else if (specialty.contains('pintor')) {
      return Icons.format_paint_rounded;
    }
    return Icons.work_rounded;
  }

  static Color getColor(String specialty) {
    specialty = specialty.toLowerCase();
    if (specialty.contains('emergencia')) {
      return const Color(0xFFFF5277); // Pink/Red from mockup
    }
    if (specialty.contains('fontanero')) {
      return const Color(0xFF0091FF); // Blue from mockup
    }
    if (specialty.contains('carpintero')) {
      return const Color(0xFF00A3FF); // Cyan/Blue from mockup
    }
    return Colors.grey;
  }
}
