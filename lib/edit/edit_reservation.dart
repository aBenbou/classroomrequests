import 'package:adv_basics/model/reservation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class EditReservation extends StatefulWidget {
  final String reservationId;

  const EditReservation({super.key, required this.reservationId});

  @override
  State<EditReservation> createState() {
    return _EditReservationState();
  }
}

class _EditReservationState extends State<EditReservation> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _dateTimeController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _professorController = TextEditingController();
  final TextEditingController _courseController = TextEditingController();
  bool _isEditing = false;
  bool _isLoading = true;
  Reservation? _reservation;
  String? _selectedClassroom;
  List<Map<String, dynamic>> _classrooms = [];
  bool _includeAmphi = false;
  bool _includeE = false;
  bool _includeTP = false;

  @override
  void initState() {
    super.initState();
    _fetchReservation();
    fetchClassrooms();
  }

  Future<void> _fetchReservation() async {
    setState(() => _isLoading = true);
    try {
      var doc = await FirebaseFirestore.instance
          .collection('reservations')
          .doc(widget.reservationId)
          .get();

      if (doc.exists) {
        _reservation = await Reservation.fromFirestore(doc);

        // Initialize fields
        _dateTimeController.text =
            DateFormat('yyyy-MM-dd – kk:mm').format(_reservation!.debut);
        _durationController.text = '${_reservation!.duree} minutes';
        _professorController.text = _reservation!.professeurNom;
        _courseController.text = _reservation!.coursIntitule;

        // Set the selected classroom based on the reservation
        // Assuming _reservation has a field like salleDetails which holds the classroom info
        _selectedClassroom = _reservation!.salleDetails;

        // Determine the classroom type for checkboxes
        var classroomType = _selectedClassroom!.split(' ')[0];
        _includeAmphi = classroomType == 'Amphi';
        _includeE = classroomType == 'E';
        _includeTP = classroomType == 'TP';
      }
    } catch (e) {
      print('Error fetching reservation: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> fetchClassrooms() async {
    try {
      var querySnapshot =
          await FirebaseFirestore.instance.collection('classrooms').get();
      _classrooms = querySnapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('Error fetching classrooms: $e');
    }
  }

  List<DropdownMenuItem<String>> getFilteredClassroomItems() {
    Set<String> uniqueClassroomDetails = {};

    // First, gather unique classroom details
    for (var classroom in _classrooms) {
      var type = classroom['type'] as String;
      if ((type == 'Amphi' && _includeAmphi) ||
          (type == 'E' && _includeE) ||
          (type == 'TP' && _includeTP)) {
        var salleDetails = _getClassroomDetails(classroom);
        uniqueClassroomDetails.add(salleDetails);
      }
    }

    // Then, create DropdownMenuItem for each unique detail
    return uniqueClassroomDetails.map<DropdownMenuItem<String>>((salleDetails) {
      return DropdownMenuItem<String>(
        value: salleDetails,
        child: Text(salleDetails),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Reservation details')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_reservation == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Reservation details')),
        body: const Center(child: Text('Reservation not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Reservation' : 'Edit Reservation'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => _isEditing = true),
            ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _confirmDelete,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildAutocompleteField('Professeur', _professorController,
                    'users', 'nom', 'prenom', !_isEditing,
                    initialValue: _reservation!.professeurNom),
                _buildAutocompleteField('Course', _courseController, 'classes',
                    'intitule', null, !_isEditing,
                    initialValue: _reservation!.coursIntitule),
                _buildDateTimeAndDurationFields(),
                _buildClassroomField(),
                const SizedBox(height: 20),
                if (_isEditing)
                  ElevatedButton(
                    onPressed: _submitUpdate,
                    child: const Text('Update Reservation'),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAutocompleteField(
      String label,
      TextEditingController controller,
      String collection,
      String displayField,
      String? secondaryField,
      bool readOnly,
      {String? initialValue}) {
    // If readOnly is true, bypass Autocomplete and just display the text.
    if (readOnly) {
      return TextFormField(
        controller: controller,
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
        ),
      );
    }

    // Autocomplete logic for when editing
    return Autocomplete<String>(
      optionsBuilder: (TextEditingValue textEditingValue) async {
        if (textEditingValue.text.isEmpty) {
          return const Iterable<String>.empty();
        }

        var query = FirebaseFirestore.instance
            .collection(collection)
            .where(displayField, isGreaterThanOrEqualTo: textEditingValue.text)
            .limit(10);

        var querySnapshot = await query.get();
        return querySnapshot.docs.map((doc) {
          return secondaryField != null
              ? '${doc[displayField]} ${doc[secondaryField]}'
              : doc[displayField];
        });
      },
      initialValue:
          initialValue != null ? TextEditingValue(text: initialValue) : null,
      fieldViewBuilder:
          (context, textEditingController, focusNode, onFieldSubmitted) {
        // If initialValue is provided, set it to the field controller.
        if (initialValue != null && textEditingController.text.isEmpty) {
          textEditingController.text = initialValue;
        }

        return TextFormField(
          controller: textEditingController,
          focusNode: focusNode,
          decoration: InputDecoration(
            labelText: label,
          ),
        );
      },
      onSelected: (String selection) {
        controller.text = selection;
      },
    );
  }

  Widget _buildDateTimeAndDurationFields() {
    return Column(
      children: [
        TextFormField(
          controller: _dateTimeController,
          decoration: const InputDecoration(
            labelText: 'Date and Time',
            suffixIcon: Icon(Icons.calendar_today),
          ),
          readOnly: !_isEditing,
          onTap: () => _isEditing ? _selectDateTime() : null,
          validator: (value) =>
              value!.isEmpty ? 'Please select date and time' : null,
        ),
        TextFormField(
          controller: _durationController,
          decoration: const InputDecoration(
            labelText: 'Duration',
            suffixIcon: Icon(Icons.timer),
          ),
          keyboardType: TextInputType.number,
          readOnly: !_isEditing,
          onTap: () => _isEditing ? _selectDuration() : null,
          validator: (value) =>
              value!.isEmpty ? 'Please select duration' : null,
        ),
      ],
    );
  }

  Widget _buildClassroomField() {
    List<DropdownMenuItem<String>> classroomItems = getFilteredClassroomItems();

    // Ensure the selected classroom is in the current list of filtered items
    if (!classroomItems.any((item) => item.value == _selectedClassroom)) {
      if (classroomItems.isNotEmpty) {
        _selectedClassroom = classroomItems
            .first.value; // Set to the first available item or a default value
      } else {
        _selectedClassroom = null; // Reset if no items are available
      }
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: DropdownButtonFormField<String>(
            value: _selectedClassroom,
            items: classroomItems,
            onChanged: _isEditing
                ? (String? newValue) {
                    setState(() => _selectedClassroom = newValue);
                  }
                : null,
            decoration: const InputDecoration(
              labelText: 'Select Classroom',
            ),
            disabledHint:
                _selectedClassroom != null ? Text(_selectedClassroom!) : null,
          ),
        ),
        if (_isEditing) ...[
          _buildCheckbox('Amphi', _includeAmphi, (bool? value) {
            setState(() {
              _includeAmphi = value ?? false;
              _updateClassroomDropdown();
            });
          }),
          _buildCheckbox('E', _includeE, (bool? value) {
            setState(() {
              _includeE = value ?? false;
              _updateClassroomDropdown();
            });
          }),
          _buildCheckbox('TP', _includeTP, (bool? value) {
            setState(() {
              _includeTP = value ?? false;
              _updateClassroomDropdown();
            });
          }),
        ],
      ],
    );
  }

  Widget _buildCheckbox(String title, bool value, Function(bool?) onChanged) {
    return Row(
      children: [
        Checkbox(
          value: value,
          onChanged: onChanged,
        ),
        Text(title),
      ],
    );
  }

  void _updateClassroomDropdown() {
    Set<String> newClassroomSet = {};

    for (var classroom in _classrooms) {
      var type = classroom['type'] as String;
      if ((type == 'Amphi' && _includeAmphi) ||
          (type == 'E' && _includeE) ||
          (type == 'TP' && _includeTP)) {
        var salleDetails = _getClassroomDetails(classroom);
        newClassroomSet.add(salleDetails);
      }
    }

    // Reset the selected classroom if it's no longer in the list
    if (!newClassroomSet.contains(_selectedClassroom)) {
      _selectedClassroom = null;
    }

    // Update the state to reflect changes
    setState(() {});
  }

  String _getClassroomDetails(Map<String, dynamic> classroom) {
    var type = classroom['type'] as String;
    var etage = classroom['etage'] as String;
    var numero = classroom['numero'] as String;
    var batiment = classroom['batiment'] as String;

    var etageNumero = "$etage$numero";
    if (type.toLowerCase() == 'amphi') {
      etageNumero = etageNumero.replaceFirst(RegExp(r'^0+'), '');
    }

    return "$type $etageNumero Bat $batiment";
  }

  Future<void> _selectDateTime() async {
    if (!_isEditing) return;

    DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (date == null || !mounted) return;

    TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (time != null && mounted) {
      setState(() {
        _dateTimeController.text = DateFormat('yyyy-MM-dd – kk:mm').format(
            DateTime(date.year, date.month, date.day, time.hour, time.minute));
      });
    }
  }

  Future<void> _selectDuration() async {
    if (!_isEditing) return;

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 0, minute: 0),
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    if (picked != null && mounted) {
      setState(() {
        int totalMinutes = picked.hour * 60 + picked.minute;
        _durationController.text = '$totalMinutes minutes';
      });
    }
  }

  Future<void> _submitUpdate() async {
    if (!_formKey.currentState!.validate()) return;

    DateTime selectedDateTime =
        DateFormat('yyyy-MM-dd – kk:mm').parse(_dateTimeController.text, true);
    int duration = int.tryParse(_durationController.text.split(' ')[0]) ?? 0;

    // Check if the reservation time is within working hours
    DateTime reservationEndTime =
        selectedDateTime.add(Duration(minutes: duration));
    if (!_isWithinWorkingHours(selectedDateTime, reservationEndTime)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Reservation time is outside working hours')),
      );
      return; // Prevent further execution if outside working hours
    }

    try {
      DocumentReference professorRef =
          await _getProfessorRef(_professorController.text);
      DocumentReference courseRef = await _getCourseRef(_courseController.text);
      DocumentReference classroomRef =
          await _getClassroomRef(_selectedClassroom!);

      // Convert the DateTime object to a Firestore Timestamp
      var startTimestamp = Timestamp.fromDate(selectedDateTime);

      await FirebaseFirestore.instance
          .collection('reservations')
          .doc(widget.reservationId)
          .update({
        'debut': startTimestamp,
        'duree': duration,
        'professeur': professorRef,
        'cours': courseRef,
        'salle': classroomRef,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Reservation updated successfully')));
        setState(() {
          _isEditing = false;
          _fetchReservation();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update reservation: $e')));
      }
    }
  }

// Helper function to check if a DateTime is within working hours
  bool _isWithinWorkingHours(DateTime startDateTime, DateTime endDateTime) {
    // Convert UTC DateTime to local time for comparison
    DateTime localStartDateTime = startDateTime.toLocal();
    DateTime localEndDateTime = endDateTime.toLocal();

    // Define working hours
    TimeOfDay workStart = const TimeOfDay(hour: 8, minute: 30);
    TimeOfDay workEnd = const TimeOfDay(hour: 18, minute: 30);

    // Check if the day is between Monday and Saturday
    bool isWeekday = localStartDateTime.weekday >= DateTime.monday &&
        localStartDateTime.weekday <= DateTime.saturday;

    // Check if start time is within working hours
    bool isStartTimeValid = localStartDateTime.hour > workStart.hour ||
        (localStartDateTime.hour == workStart.hour &&
            localStartDateTime.minute >= workStart.minute);

    // Check if end time is within working hours
    bool isEndTimeValid = localEndDateTime.hour < workEnd.hour ||
        (localEndDateTime.hour == workEnd.hour &&
            localEndDateTime.minute <= workEnd.minute);

    return isWeekday && isStartTimeValid && isEndTimeValid;
  }

  Future<void> _deleteReservation() async {
    try {
      await FirebaseFirestore.instance
          .collection('reservations')
          .doc(widget.reservationId)
          .delete();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Reservation deleted successfully')));

        // Wait for 2 seconds and then navigate to the homepage
        Future.delayed(const Duration(seconds: 2), () {
          Navigator.of(context).pushReplacementNamed('/home', arguments: 1);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete reservation: $e')));
      }
    }
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content:
              const Text('Are you sure you want to delete this reservation?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog first
                _deleteReservation(); // Then call delete reservation
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Future<DocumentReference> _getDocumentReference(
      String collection, String field, String value,
      [String? field2, String? value2]) async {
    var query = FirebaseFirestore.instance
        .collection(collection)
        .where(field, isEqualTo: value);
    if (field2 != null && value2 != null) {
      query = query.where(field2, isEqualTo: value2);
    }
    var querySnapshot = await query.limit(1).get();
    if (querySnapshot.docs.isEmpty) {
      throw 'Document not found';
    }
    return querySnapshot.docs.first.reference;
  }

  Future<DocumentReference> _getProfessorRef(String fullName) async {
    var nameParts = fullName.split(' ');
    if (nameParts.length < 2) {
      throw 'Invalid professor name format';
    }
    return await _getDocumentReference(
        'users', 'nom', nameParts[0], 'prenom', nameParts[1]);
  }

  Future<DocumentReference> _getCourseRef(String courseTitle) async {
    return await _getDocumentReference('classes', 'intitule', courseTitle);
  }

  Future<DocumentReference> _getClassroomRef(String classroomDetails) async {
    var details = classroomDetails.split(' ');
    if (details.length < 4) {
      throw 'Invalid classroom details';
    }
    String type = details[0];
    String etage = (type == 'Amphi') ? '0' : details[1].substring(0, 1);
    String numero = (type == 'Amphi')
        ? details[1].padLeft(2, '0')
        : details[1].substring(1).padLeft(2, '0');
    String batiment = details[3];

    var querySnapshot = await FirebaseFirestore.instance
        .collection('classrooms')
        .where('type', isEqualTo: type)
        .where('etage', isEqualTo: etage)
        .where('numero', isEqualTo: numero)
        .where('batiment', isEqualTo: batiment)
        .limit(1)
        .get();

    if (querySnapshot.docs.isEmpty) {
      throw 'Classroom not found';
    }
    return querySnapshot.docs.first.reference;
  }
}
