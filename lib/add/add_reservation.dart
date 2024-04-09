import 'package:adv_basics/home/home_page_admin.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AddReservation extends StatefulWidget {
  const AddReservation({super.key});

  @override
  State<AddReservation> createState() {
    return _AddReservationState();
  }
}

class _AddReservationState extends State<AddReservation> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _dateTimeController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _professorController = TextEditingController();
  final TextEditingController _courseController = TextEditingController();
  bool _includeAmphi = false;
  bool _includeE = false;
  bool _includeTP = false;
  String? _selectedClassroom;
  List<Map<String, dynamic>> _classrooms = [];

  @override
  void initState() {
    super.initState();
    fetchClassrooms();
  }

  Future<void> fetchClassrooms() async {
    var querySnapshot =
        await FirebaseFirestore.instance.collection('classrooms').get();
    _classrooms = querySnapshot.docs.map((doc) => doc.data()).toList();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add a Reservation'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => const HomePage(initialPage: 1),
              ),
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildAutocompleteField('Professeur', _professorController,
                    'users', 'nom', 'prenom'),
                _buildAutocompleteField(
                    'Course', _courseController, 'classes', 'intitule', null),
                TextFormField(
                  controller: _dateTimeController,
                  decoration: const InputDecoration(
                    labelText: 'Date and Time',
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  readOnly: true,
                  onTap: () => _selectDateTime(),
                  validator: (value) =>
                      value!.isEmpty ? 'Please select date and time' : null,
                ),
                TextFormField(
                  controller: _durationController,
                  decoration: const InputDecoration(
                    labelText: 'Duration',
                    suffixIcon: Icon(Icons.timer),
                  ),
                  readOnly: true,
                  onTap: () => _selectDuration(),
                  validator: (value) =>
                      value!.isEmpty ? 'Please select duration' : null,
                ),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedClassroom,
                        items: getFilteredClassroomItems(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedClassroom = newValue;
                          });
                        },
                        decoration: const InputDecoration(
                          labelText: 'Select Classroom',
                        ),
                      ),
                    ),
                    Checkbox(
                      value: _includeAmphi,
                      onChanged: (bool? value) {
                        setState(() {
                          _includeAmphi = value ?? false;
                        });
                      },
                    ),
                    const Text('Amphi'),
                    Checkbox(
                      value: _includeE,
                      onChanged: (bool? value) {
                        setState(() {
                          _includeE = value ?? false;
                        });
                      },
                    ),
                    const Text('E'),
                    Checkbox(
                      value: _includeTP,
                      onChanged: (bool? value) {
                        setState(() {
                          _includeTP = value ?? false;
                        });
                      },
                    ),
                    const Text('TP'),
                  ],
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _submitReservation,
                  child: const Text('Submit Reservation'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAutocompleteField(String label, TextEditingController controller,
      String collection, String displayField, String? secondaryField) {
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
      fieldViewBuilder:
          (context, textEditingController, focusNode, onFieldSubmitted) {
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

  Future<void> _selectDateTime() async {
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
        // Converting the time picker's 24-hour format to a 12-hour range for duration
        int totalMinutes = (picked.hour % 12) * 60 + picked.minute;
        _durationController.text = '$totalMinutes minutes';
      });
    }
  }

  void _submitReservation() async {
    if (_formKey.currentState!.validate()) {
      bool wasSubmissionSuccessful = false;
      String message = '';

      var selectedProfessorName = _professorController.text.split(' ');
      var selectedCourseTitle = _courseController.text;
      var selectedDateTime = _dateTimeController.text;
      var selectedDuration = int.parse(_durationController.text.split(' ')[0]);

      // Parsing the selected datetime as local time and then converting it to UTC
      var selectedDateTimeObject = DateFormat('yyyy-MM-dd – kk:mm')
          .parse(selectedDateTime, true)
          .toUtc();

      var reservationEndTime =
          selectedDateTimeObject.add(Duration(minutes: selectedDuration));

      // Check if the reservation time is within working hours
      if (!_isWithinWorkingHours(selectedDateTimeObject, reservationEndTime)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Reservation time is outside working hours')),
        );
        return; // Prevent further execution if outside working hours
      }

      // Convert the DateTime object to a Firestore Timestamp
      var startTimestamp = Timestamp.fromDate(selectedDateTimeObject);

      // Adding print statements to see the selected and parsed DateTime objects
      print("Selected Date and Time (from controller): $selectedDateTime");
      print("Parsed UTC DateTime object: $selectedDateTimeObject");
      print("Firestore Timestamp: $startTimestamp");

      try {
        var professorRef = await _getDocumentReference('users', 'nom',
            selectedProfessorName[0], 'prenom', selectedProfessorName[1]);
        var courseRef = await _getDocumentReference(
            'classes', 'intitule', selectedCourseTitle);

        var classroomDetails = _selectedClassroom?.split(' ');

        if (classroomDetails == null || classroomDetails.length < 4) {
          throw 'Invalid classroom details';
        }

        String type = classroomDetails[0];
        String etage;
        String numero;
        String batiment = classroomDetails[3];

        if (type == 'Amphi') {
          etage = '0';
          numero = classroomDetails[1].padLeft(2, '0');
        } else {
          etage = classroomDetails[1].substring(0, 1);
          numero = classroomDetails[1].substring(1).padLeft(2, '0');
        }

        var classroomQuerySnapshot = await FirebaseFirestore.instance
            .collection('classrooms')
            .where('type', isEqualTo: type)
            .where('etage', isEqualTo: etage)
            .where('numero', isEqualTo: numero)
            .where('batiment', isEqualTo: batiment)
            .get();

        if (classroomQuerySnapshot.docs.isEmpty) {
          throw 'Classroom not found';
        }

        var classroomRef = classroomQuerySnapshot.docs.first.reference;

        await FirebaseFirestore.instance.collection('reservations').add({
          'professeur': professorRef,
          'cours': courseRef,
          'debut': startTimestamp,
          'duree': selectedDuration,
          'salle': classroomRef,
        });

        print(
            "Reservation added to Firestore with start time: $startTimestamp");

        wasSubmissionSuccessful = true;
      } catch (e) {
        message = 'Failed to add reservation: $e';
        wasSubmissionSuccessful = false;
        print(message);
      }

      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(message)));
        if (wasSubmissionSuccessful) {
          Navigator.of(context).pushReplacementNamed('/home');
        }
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
}
