import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:adv_basics/model/reclamation.dart';

String formatDayOfWeek(DateTime date) {
  String formattedDate = DateFormat('EEEE', 'fr_FR').format(date);
  return '${formattedDate[0].toUpperCase()}${formattedDate.substring(1)}';
}

class ReclamationTile extends StatelessWidget {
  final Reclamation reclamation;
  final VoidCallback? onTap;

  const ReclamationTile({super.key, required this.reclamation, this.onTap});

  @override
  Widget build(BuildContext context) {
    String dayOfWeek = formatDayOfWeek(reclamation.reservation.debut);
    String time =
        DateFormat('HH:mm', 'fr_FR').format(reclamation.reservation.debut);

    // Determine icon and color based on user category
    Color tileColor;
    IconData leadingIcon;
    switch (reclamation.user.category.toLowerCase()) {
      case 'professeur':
        tileColor = Colors.green;
        leadingIcon = Icons.school;
        break;
      case 'securite':
        tileColor = Colors.red;
        leadingIcon = Icons.security;
        break;
      default:
        tileColor = Colors.blue;
        leadingIcon = Icons.business_center;
        break;
    }

    return Card(
      margin: const EdgeInsets.all(8.0),
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(leadingIcon, color: tileColor, size: 30),
        title: Text(
          '$dayOfWeek $time', // Use formatted day of the week and time
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18, // Slightly larger font size
            color: Colors.black,
          ),
        ),
        subtitle: Text(
          '${reclamation.reservation.salleDetails}\n${reclamation.user.nom} ${reclamation.user.prenom}\n${reclamation.description}',
        ),
        onTap: onTap,
      ),
    );
  }
}
