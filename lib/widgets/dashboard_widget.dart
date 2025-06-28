import 'package:flutter/material.dart';

Widget dashboardCard(String title, String count, IconData icon, Color color) {
  return Container(
    width: 160,
    height: 100,
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.white, size: 30),
        const Spacer(),
        Text(title, style: const TextStyle(color: Colors.white, fontSize: 20)),
        Text(
          count,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  );
}
