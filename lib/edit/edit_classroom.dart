import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:adv_basics/model/classroom.dart';

class EditClassroom extends StatefulWidget {
  final String classroomId;
  final VoidCallback onUpdated;

  const EditClassroom(
      {super.key, required this.classroomId, required this.onUpdated});

  @override
  State<EditClassroom> createState() {
    return _EditClassroomState();
  }
}

class _EditClassroomState extends State<EditClassroom> {
  final _formKey = GlobalKey<FormState>();
  final _numeroController = TextEditingController();
  final _etageController = TextEditingController();
  final _batimentController = TextEditingController();
  String _selectedType = 'E';
  Classroom? _classroom;
  bool _isEditing = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchClassroom();
  }

  Future<void> _fetchClassroom() async {
    setState(() => _isLoading = true);
    try {
      var doc = await FirebaseFirestore.instance
          .collection('classrooms')
          .doc(widget.classroomId)
          .get();

      if (doc.exists) {
        _classroom = Classroom.fromFirestore(doc);
        _numeroController.text = _classroom!.numero;
        _etageController.text = _classroom!.etage;
        _batimentController.text = _classroom!.batiment;
        _selectedType = _classroom!.type;
      }
    } catch (e) {
      print('Error fetching classroom: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Classroom Details')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_classroom == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Classroom Details')),
        body: const Center(child: Text('Classroom not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Classroom' : 'Classroom Details'),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _numeroController,
                  decoration: const InputDecoration(labelText: 'Numero'),
                  readOnly: !_isEditing,
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter numero' : null,
                ),
                TextFormField(
                  controller: _etageController,
                  decoration: const InputDecoration(labelText: 'Etage'),
                  readOnly: !_isEditing,
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter etage' : null,
                ),
                TextFormField(
                  controller: _batimentController,
                  decoration: const InputDecoration(labelText: 'Batiment'),
                  readOnly: !_isEditing,
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter batiment' : null,
                ),
                ..._buildTypeRadioList(),
                const SizedBox(height: 20),
                if (_isEditing)
                  Center(
                    child: ElevatedButton(
                      onPressed: _submitUpdate,
                      child: const Text('Update Classroom'),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildTypeRadioList() {
    return ['E', 'TP', 'Amphi'].map((type) {
      return RadioListTile<String>(
        title: Text(type),
        value: type,
        groupValue: _selectedType,
        onChanged: _isEditing
            ? (newValue) => setState(() => _selectedType = newValue!)
            : null,
        dense: true,
      );
    }).toList();
  }

  Future<void> _submitUpdate() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      await FirebaseFirestore.instance
          .collection('classrooms')
          .doc(widget.classroomId)
          .update({
        'type': _selectedType,
        'etage': _etageController.text,
        'numero': _numeroController.text,
        'batiment': _batimentController.text,
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Classroom updated successfully')));
      widget.onUpdated();
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update classroom: $e')));
    }
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content:
              const Text('Are you sure you want to delete this classroom?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog first
                _deleteClassroom(); // Then call delete classroom
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteClassroom() async {
    try {
      await FirebaseFirestore.instance
          .collection('classrooms')
          .doc(widget.classroomId)
          .delete();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Classroom deleted successfully')),
      );

      widget.onUpdated();
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete classroom: $e')),
      );
    }
  }
}
