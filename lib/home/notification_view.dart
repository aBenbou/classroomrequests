import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:adv_basics/model/notification.dart' as model;
import 'package:adv_basics/add/add_reclamation.dart';
import 'dart:async';

class NotificationView extends StatefulWidget {
  final model.Notification notification;
  final VoidCallback onNotificationStatusChanged;

  const NotificationView(
      {super.key,
      required this.notification,
      required this.onNotificationStatusChanged});

  @override
  State<NotificationView> createState() {
    return _NotificationViewState();
  }
}

class _NotificationViewState extends State<NotificationView> {
  late Timer _timer;
  String _timeRemaining = '';
  bool isDone;

  // Initialize 'isDone' in the constructor
  _NotificationViewState() : isDone = false;

  @override
  void initState() {
    super.initState();
    isDone = widget.notification.done;
    _timer =
        Timer.periodic(const Duration(seconds: 1), (Timer t) => _updateTime());
    _updateTime();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _updateTime() {
    final now = DateTime.now();
    final endTime = widget.notification.reservation.debut
        .add(Duration(minutes: widget.notification.reservation.duree));

    if (now.isBefore(endTime)) {
      final difference = endTime.difference(now);
      setState(() {
        _timeRemaining =
            '${difference.inHours.toString().padLeft(2, '0')}:${difference.inMinutes.remainder(60).toString().padLeft(2, '0')}:${difference.inSeconds.remainder(60).toString().padLeft(2, '0')}';
      });
    } else {
      setState(() {
        _timeRemaining = 'Expired';
      });
    }
  }

  Future<void> _toggleNotificationStatus(BuildContext context) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      await model.Notification.toggleNotificationStatus(widget.notification.id);

      // Fetch the updated notification to get the new 'done' status
      DocumentSnapshot updatedNotificationSnapshot = await FirebaseFirestore
          .instance
          .collection('notifications')
          .doc(widget.notification.id)
          .get();
      bool updatedStatus = updatedNotificationSnapshot['done'];

      // Update the 'isDone' state variable
      setState(() {
        isDone = updatedStatus;
      });

      widget.onNotificationStatusChanged();

      scaffoldMessenger.showSnackBar(
        SnackBar(
            content: Text(isDone ? 'Marked as Opened' : 'Marked as Closed')),
      );
    } catch (error) {
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('Failed to update notification status.')),
      );
    }
  }

  void _navigateToAddReclamation() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddReclamation(
          initialReservation: widget.notification.reservation,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    DateTime endTime = widget.notification.reservation.debut
        .add(Duration(minutes: widget.notification.reservation.duree));
    IconData doorIcon =
        widget.notification.done ? Icons.door_front_door : Icons.door_back_door;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Details'),
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
                CircleAvatar(
                  radius: 50,
                  child: Icon(doorIcon, size: 50),
                ),
                const SizedBox(height: 20),
                Text(
                  widget.notification.reservation.coursIntitule,
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                Text(
                  widget.notification.reservation.professeurNom,
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                Text(
                  widget.notification.reservation.salleDetails,
                  textAlign: TextAlign.center,
                ),
                Text(
                  DateFormat('dd-MM-yyyy')
                      .format(widget.notification.reservation.debut),
                  textAlign: TextAlign.center,
                ),
                Text(
                  'From: ${DateFormat('kk:mm').format(widget.notification.reservation.debut)} - To: ${DateFormat('kk:mm').format(endTime)}',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8.0),
                Text(
                  'Time Remaining: $_timeRemaining',
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _navigateToAddReclamation,
                  child: const Text('Add Reclamation'),
                ),
                ElevatedButton(
                  onPressed: () => _toggleNotificationStatus(context),
                  child: Text(isDone ? 'Mark as Closed' : 'Mark as Opened'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
