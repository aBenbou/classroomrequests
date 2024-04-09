import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:adv_basics/model/user.dart';
import 'package:adv_basics/model/reservation.dart';

class Reclamation {
  final String id;
  final String description;
  final Reservation reservation;
  final User user;

  Reclamation({
    required this.id,
    required this.description,
    required this.reservation,
    required this.user,
  });

  static Future<Reclamation> fromFirestore(DocumentSnapshot doc) async {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    // Fetch reservation and user references
    DocumentReference reservationRef = data['reservation'];
    DocumentReference userRef = data['user'];

    // Retrieve reservation and user data
    Reservation reservation =
        await Reservation.fromFirestore(await reservationRef.get());
    User user = await User.fromFirestore(await userRef.get());

    return Reclamation(
      id: doc.id,
      description: data['description'],
      reservation: reservation,
      user: user,
    );
  }
}
