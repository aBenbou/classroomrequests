import 'package:cloud_firestore/cloud_firestore.dart';

class Reservation {
  final String id;
  final String coursIntitule;
  final DateTime debut;
  final int duree;
  final String professeurNom;
  final String salleDetails;

  Reservation({
    required this.id,
    required this.coursIntitule,
    required this.debut,
    required this.duree,
    required this.professeurNom,
    required this.salleDetails,
  });

  static Future<Reservation> fromFirestore(DocumentSnapshot doc) async {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    // Fetching 'cours' (classes) reference
    var coursRef = data['cours'];
    String intitule;
    if (coursRef is DocumentReference) {
      DocumentSnapshot coursDoc = await coursRef.get();
      intitule = coursDoc['intitule'];
    } else if (coursRef is String) {
      intitule = coursRef;
    } else {
      throw 'Invalid data type for cours';
    }

    // Fetching 'professeur' (users) reference
    var professeurRef = data['professeur'];
    String professeurNom;
    if (professeurRef is DocumentReference) {
      DocumentSnapshot professeurDoc = await professeurRef.get();
      professeurNom = "${professeurDoc['nom']} ${professeurDoc['prenom']}";
    } else if (professeurRef is String) {
      professeurNom = professeurRef;
    } else {
      throw 'Invalid data type for professeur';
    }

    // Fetching 'salle' (classrooms) reference
    var salleRef = data['salle'];
    String salleDetails;
    if (salleRef is DocumentReference) {
      DocumentSnapshot salleDoc = await salleRef.get();
      String type = salleDoc['type'];
      String etageNumero = salleDoc['etage'] + salleDoc['numero'];
      String batiment = salleDoc['batiment'];

      if (type.toLowerCase() == 'amphi') {
        etageNumero = etageNumero.replaceFirst(RegExp(r'^0+'), '');
      }
      salleDetails = "$type $etageNumero Bat $batiment";
    } else if (salleRef is String) {
      salleDetails = salleRef;
    } else {
      throw 'Invalid data type for salle';
    }

    return Reservation(
      id: doc.id,
      coursIntitule: intitule,
      debut: (data['debut'] as Timestamp).toDate(),
      duree: data['duree'],
      professeurNom: professeurNom,
      salleDetails: salleDetails,
    );
  }
}
