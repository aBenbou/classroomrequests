import 'package:flutter/material.dart';
import 'package:adv_basics/model/classe.dart';

class ClasseTile extends StatelessWidget {
  final Classe classe;
  final VoidCallback? onTap;

  const ClasseTile({super.key, required this.classe, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.all(8.0),
        elevation: 4.0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          title: Text(
            classe.intitule,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          subtitle: Text('Volume Horaire: ${classe.volumeHoraire} hours'),
        ),
      ),
    );
  }
}
