import 'package:flutter/material.dart';
import 'package:adv_basics/model/reservation.dart';
import 'package:intl/intl.dart';

class ReservationTile extends StatelessWidget {
  final Reservation reservation;
  final VoidCallback onTap; // Add this line

  const ReservationTile(
      {super.key, required this.reservation, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.all(8.0),
        elevation: 4.0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildTitle(),
              const SizedBox(height: 8),
              buildDateRow(),
              const SizedBox(height: 4),
              buildTimeRow(),
              const SizedBox(height: 4),
              buildRoomRow(),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTitle() {
    return Text(
      reservation.coursIntitule, // Use coursIntitule as the title
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  Widget buildDateRow() {
    return Row(
      children: <Widget>[
        const Icon(Icons.calendar_today, size: 16),
        const SizedBox(width: 8),
        Text(DateFormat('yyyy-MM-dd').format(reservation.debut)), // Format date
      ],
    );
  }

  Widget buildTimeRow() {
    String formattedTime =
        DateFormat('HH:mm').format(reservation.debut); // Format time
    return Row(
      children: <Widget>[
        const Icon(Icons.access_time, size: 16),
        const SizedBox(width: 8),
        Text(formattedTime),
      ],
    );
  }

  Widget buildRoomRow() {
    return Row(
      children: <Widget>[
        const Icon(Icons.meeting_room, size: 16),
        const SizedBox(width: 8),
        Text(reservation.salleDetails), // Display salle details
      ],
    );
  }
}
