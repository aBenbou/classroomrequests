import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:intl/intl.dart';
import 'package:adv_basics/model/reservation.dart';

class AddReclamation extends StatefulWidget {
  final Reservation? initialReservation;

  const AddReclamation({
    super.key,
    this.initialReservation,
  });

  @override
  State<AddReclamation> createState() => _AddReclamationState();
}

class _AddReclamationState extends State<AddReclamation> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _descriptionController = TextEditingController();
  String? _selectedReservationId;
  List<Reservation> _reservations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchReservations();
    if (widget.initialReservation != null) {
      _selectedReservationId = widget.initialReservation!.id;
    }
  }

  Future<void> fetchReservations() async {
    setState(() => _isLoading = true);
    try {
      var user = auth.FirebaseAuth.instance.currentUser;
      if (user == null) throw 'User not authenticated';

      // Assuming the 'professeur' field is a document reference to the users collection.
      DocumentReference userRef =
          FirebaseFirestore.instance.collection('users').doc(user.uid);

      var reservationsQuery = await FirebaseFirestore.instance
          .collection('reservations')
          .where('professeur',
              isEqualTo: userRef) // Use the DocumentReference here.
          .get();

      var reservationDocs = reservationsQuery.docs;

      // If using async methods to parse documents, use Future.wait to resolve all futures.
      List<Reservation> fetchedReservations = await Future.wait(
        reservationDocs
            .map((doc) async => await Reservation.fromFirestore(doc)),
      );

      setState(() {
        _reservations = fetchedReservations;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching reservations: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Add Reclamation')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Reclamation'),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  value: _selectedReservationId,
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedReservationId = newValue;
                    });
                  },
                  items: _reservations
                      .map<DropdownMenuItem<String>>((reservation) {
                    return DropdownMenuItem<String>(
                      value: reservation.id,
                      child: Text(
                          '${reservation.coursIntitule} - ${DateFormat('yyyy-MM-dd – kk:mm').format(reservation.debut)}'),
                    );
                  }).toList(),
                  decoration: const InputDecoration(
                    labelText: 'Select Reservation',
                  ),
                  validator: (value) =>
                      value == null ? 'Please select a reservation' : null,
                ),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _submitReclamation,
                  child: const Text('Submit Reclamation'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _submitReclamation() async {
    if (_formKey.currentState!.validate()) {
      try {
        var user = auth.FirebaseAuth.instance.currentUser;
        if (user == null) throw 'User not authenticated';

        await FirebaseFirestore.instance.collection('reclamations').add({
          'description': _descriptionController.text,
          'reservation': FirebaseFirestore.instance
              .collection('reservations')
              .doc(_selectedReservationId),
          'user': FirebaseFirestore.instance.collection('users').doc(user.uid),
        });

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reclamation submitted successfully')),
        );

        Navigator.of(context).pop(true);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit reclamation: $e')),
        );
      }
    }
  }
}
