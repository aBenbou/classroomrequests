import 'package:flutter/material.dart';
import 'package:adv_basics/model/notification.dart' as model;
import 'package:intl/intl.dart';
import 'dart:async';

class NotificationTile extends StatefulWidget {
  final model.Notification notification;
  final VoidCallback? onTap;

  const NotificationTile({super.key, required this.notification, this.onTap});

  @override
  State<NotificationTile> createState() => _NotificationTileState();
}

class _NotificationTileState extends State<NotificationTile> {
  late Timer _timer;
  late String _timeRemaining;
  late String _status;
  late Color _cardColor;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _updateTimeRemaining();
      });
    });
    _updateTimeRemaining();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _updateTimeRemaining() {
    final now = DateTime.now();
    final start = widget.notification.reservation.debut;
    final end =
        start.add(Duration(minutes: widget.notification.reservation.duree));
    final fifteenMinutesBeforeStart =
        start.subtract(const Duration(minutes: 15));

    if (now.isAfter(fifteenMinutesBeforeStart) && now.isBefore(start)) {
      final difference = start.difference(now);
      _timeRemaining =
          '${difference.inHours.toString().padLeft(2, '0')}:${difference.inMinutes.remainder(60).toString().padLeft(2, '0')}:${difference.inSeconds.remainder(60).toString().padLeft(2, '0')}';
      _status = 'Starting Soon';
    } else if (now.isAfter(start) && now.isBefore(end)) {
      _timeRemaining = '';
      _status = widget.notification.done ? 'Ongoing' : 'Request Attention';
    } else if (now.isAfter(end)) {
      _timeRemaining = '';
      _status = 'Finished';
    } else {
      _timeRemaining = 'Not Started';
      _status = '';
    }

    // Color based only on the 'done' attribute
    _cardColor =
        widget.notification.done ? Colors.lightGreen : Colors.orangeAccent;
  }

  @override
  Widget build(BuildContext context) {
    String dayOfWeek = DateFormat('EEEE', 'fr_FR')
        .format(widget.notification.reservation.debut);
    String time = DateFormat('HH:mm', 'fr_FR')
        .format(widget.notification.reservation.debut);

    IconData leadingIcon;
    if (_status == 'Starting Soon') {
      leadingIcon = Icons.schedule;
    } else if (_status == 'Ongoing') {
      leadingIcon = Icons.play_circle_fill;
    } else {
      leadingIcon = Icons.done;
    }

    return Card(
      margin: const EdgeInsets.all(8.0),
      color: _cardColor,
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(leadingIcon, color: Colors.white, size: 30),
        title: Text(
          '$dayOfWeek $time',
          style: const TextStyle(
              fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
        ),
        subtitle: Text(
          '${widget.notification.reservation.salleDetails}\n${widget.notification.reservation.professeurNom}\n${_timeRemaining.isNotEmpty ? "Time Remaining: $_timeRemaining\n" : ""}Status: $_status',
          style: const TextStyle(color: Colors.white),
        ),
        onTap: widget.onTap,
      ),
    );
  }
}
