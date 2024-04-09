import 'package:flutter/material.dart';
import 'package:adv_basics/model/user.dart';

class UserTile extends StatelessWidget {
  final User user;
  final VoidCallback? onTap; // Add this line

  const UserTile({super.key, required this.user, this.onTap});

  @override
  Widget build(BuildContext context) {
    IconData categoryIcon = Icons.person;

    switch (user.category.toLowerCase()) {
      case 'professeur':
        categoryIcon = Icons.school;
        break;
      case 'security':
        categoryIcon = Icons.security;
        break;
      case 'administrateur':
        categoryIcon = Icons.business_center;
        break;
    }

    return Card(
      margin: const EdgeInsets.all(8.0),
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(categoryIcon, size: 30),
        title: Text(
          '${user.nom} ${user.prenom}',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        subtitle: Text(user.category),
        onTap: onTap,
      ),
    );
  }
}
