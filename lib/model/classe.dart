import 'package:cloud_firestore/cloud_firestore.dart';

class Classe {
  final String id;
  final String intitule;
  final int volumeHoraire;

  Classe(
      {required this.id, required this.intitule, required this.volumeHoraire});

  static Classe fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Classe(
      id: doc.id,
      intitule: data['intitule'] ?? '',
      volumeHoraire: data['volume_horaire'] ?? 0,
    );
  }
}
