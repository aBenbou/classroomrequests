import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:adv_basics/model/reservation.dart';

class Notification {
  final String id;
  final Reservation reservation;
  final bool done;
  final DateTime time;

  Notification({
    required this.id,
    required this.reservation,
    required this.done,
    required this.time,
  });

  static Future<Notification> fromFirestore(DocumentSnapshot doc) async {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    // Fetch reservation reference
    DocumentReference reservationRef = data['reservation'] as DocumentReference;
    ;

    // Retrieve reservation data
    Reservation reservation =
        await Reservation.fromFirestore(await reservationRef.get());

    return Notification(
      id: doc.id,
      reservation: reservation,
      done: data['done'] ?? false,
      time: (data['time'] as Timestamp).toDate(),
    );
  }

  static Future<DocumentReference?> addNewNotification(
      Reservation reservation) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Convert current time to UTC
    DateTime now = DateTime.now().toUtc();
    // Convert reservation start and end times to UTC
    DateTime debut = reservation.debut.toUtc();
    DateTime end = debut.add(Duration(minutes: reservation.duree)).toUtc();
    DateTime fifteenMinutesBefore =
        debut.subtract(const Duration(minutes: 15)).toUtc();

    print('Current UTC time: $now'); // Updated print statement
    print('Reservation start UTC time: $debut'); // Updated print statement
    print('Reservation end UTC time: $end'); // Updated print statement

    if (now.isAfter(fifteenMinutesBefore) && now.isBefore(end)) {
      Map<String, dynamic> notificationData = {
        'reservation': firestore.collection('reservations').doc(reservation.id),
        'done': false,
        'time': Timestamp.fromDate(now), // Use the UTC DateTime object here
      };

      print('Adding new notification...'); // Existing print statement
      return await firestore.collection('notifications').add(notificationData);
    } else {
      print(
          'Current time not within the specified range.'); // Existing print statement
      return null;
    }
  }

  static Future<List<Notification>> getPendingNotifications(
      DateTime date) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Ensure the date range is set correctly for the current day
    DateTime startOfDay = DateTime(date.year, date.month, date.day).toUtc();
    DateTime endOfDay =
        DateTime(date.year, date.month, date.day, 23, 59, 59).toUtc();

    var querySnapshot = await firestore
        .collection('notifications')
        .where('time', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('time', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
        .get();

    List<Notification> notifications = [];
    for (var doc in querySnapshot.docs) {
      print("Raw notification data: ${doc.data()}"); // Detailed log

      var reservationRef = doc['reservation'] as DocumentReference;
      var reservationDoc = await reservationRef.get();
      print("Raw reservation data: ${reservationDoc.data()}"); // Detailed log

      var reservation = await Reservation.fromFirestore(reservationDoc);

      notifications.add(Notification(
        id: doc.id,
        reservation: reservation,
        done: doc['done'],
        time: (doc['time'] as Timestamp).toDate(),
      ));
    }

    return notifications;
  }

  static Future<void> markNotificationAsDone(Reservation reservation) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Query to find the corresponding notification
    var querySnapshot = await firestore
        .collection('notifications')
        .where('reservation',
            isEqualTo: firestore.collection('reservations').doc(reservation.id))
        .get();

    // Iterate over the documents and update the 'done' field
    for (var doc in querySnapshot.docs) {
      await firestore
          .collection('notifications')
          .doc(doc.id)
          .update({'done': true});
    }
  }

  static Future<void> toggleNotificationStatus(String notificationId) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Fetch the current notification document
    DocumentSnapshot notificationSnapshot =
        await firestore.collection('notifications').doc(notificationId).get();

    if (notificationSnapshot.exists) {
      // Get the current 'done' status and invert it
      bool currentStatus = notificationSnapshot['done'];
      bool newStatus = !currentStatus;

      // Update the 'done' status in Firestore
      await firestore
          .collection('notifications')
          .doc(notificationId)
          .update({'done': newStatus});
    } else {
      throw Exception('Notification not found');
    }
  }
}
