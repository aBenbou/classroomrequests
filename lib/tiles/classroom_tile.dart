import 'package:flutter/material.dart';
import 'package:adv_basics/model/classroom.dart';

class ClassroomTile extends StatelessWidget {
  final Classroom classroom;
  final VoidCallback? onTap;

  const ClassroomTile({super.key, required this.classroom, this.onTap});

  @override
  Widget build(BuildContext context) {
    IconData iconData;
    String title;
    switch (classroom.type.toLowerCase()) {
      case 'amphi':
        iconData = Icons
            .account_balance; // Represents lecture halls or large meeting spaces
        title = 'Amphitheatre';
        break;
      case 'e':
        iconData = Icons.class_; // Represents a standard classroom
        title = 'Salle TP/TD';
        break;
      case 'tp':
        iconData = Icons.computer; // Represents computer labs
        title = 'Salle TP';
        break;
      default:
        iconData = Icons.domain; // Generic icon for other types of rooms
        title = 'Classroom';
    }

    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 4,
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: ListTile(
          leading: Icon(iconData, size: 30),
          title: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          subtitle: Text(classroom.salleDetails),
        ),
      ),
    );
  }
}
