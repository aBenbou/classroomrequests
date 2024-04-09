import 'package:adv_basics/add/add_reclamation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:adv_basics/model/reservation.dart';
import 'package:adv_basics/model/notification.dart' as model;
import 'package:cloud_firestore/cloud_firestore.dart';

class ReservationView extends StatelessWidget {
  final Reservation reservation;

  const ReservationView({super.key, required this.reservation});

  Future<void> _notifySecurity(
      VoidCallback onSuccess, VoidCallback onError) async {
    print('Attempting to notify security...'); // New print statement
    DocumentReference? notificationRef =
        await model.Notification.addNewNotification(reservation);

    if (notificationRef != null) {
      print('Notification sent successfully!'); // New print statement
      onSuccess();
    } else {
      print('Failed to send notification.'); // New print statement
      onError();
    }
  }

  void _navigateToAddReclamation(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddReclamation(
          initialReservation: reservation,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    DateTime endTime =
        reservation.debut.add(Duration(minutes: reservation.duree));
    void onSuccess() {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notification sent to security.')));
    }

    void onError() {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to send notification.')));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reservation Details'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                const SizedBox(height: 20),
                const CircleAvatar(
                  radius: 50, // Placeholder for reservation icon
                  child: Icon(Icons.event_seat, size: 50),
                ),
                const SizedBox(height: 20),
                Text(
                  reservation.coursIntitule,
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                Text(
                  reservation.professeurNom,
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8.0),
                Text(
                  reservation.salleDetails,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8.0),
                Text(
                  DateFormat('dd-MM-yyyy').format(reservation.debut),
                  textAlign: TextAlign.center,
                ),
                Text(
                  'From: ${DateFormat('kk:mm').format(reservation.debut)} - To: ${DateFormat('kk:mm').format(endTime)}',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => _notifySecurity(onSuccess, onError),
                  child: const Text('Notify Security to Open Door'),
                ),
                ElevatedButton(
                  onPressed: () => _navigateToAddReclamation(context),
                  child: const Text('Add Reclamation'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
