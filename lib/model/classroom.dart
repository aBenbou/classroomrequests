import 'package:cloud_firestore/cloud_firestore.dart';

class Classroom {
  final String id;
  final String batiment;
  final String etage;
  final String numero;
  final String type;

  Classroom(
      {required this.id,
      required this.batiment,
      required this.etage,
      required this.numero,
      required this.type});

  static Classroom fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Classroom(
      id: doc.id,
      batiment: data['batiment'] ?? '',
      etage: data['etage'] ?? '',
      numero: data['numero'] ?? '',
      type: data['type'] ?? '',
    );
  }

  // Method to get formatted classroom details
  String get salleDetails {
    String etageNumero = etage + numero;
    if (type.toLowerCase() == 'amphi') {
      etageNumero = etageNumero.replaceFirst(RegExp(r'^0+'), '');
    }
    return "$type $etageNumero Bat $batiment";
  }
}
