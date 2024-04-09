import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:adv_basics/model/classe.dart';

class EditClasse extends StatefulWidget {
  final String classeId;
  final VoidCallback onUpdated;

  const EditClasse(
      {super.key, required this.classeId, required this.onUpdated});

  @override
  State<EditClasse> createState() {
    return _EditClasseState();
  }
}

class _EditClasseState extends State<EditClasse> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _intituleController = TextEditingController();
  final TextEditingController _volumeHoraireController =
      TextEditingController();
  bool _isEditing = false;
  bool _isLoading = true;
  Classe? _classe;

  @override
  void initState() {
    super.initState();
    _fetchClasse();
  }

  Future<void> _fetchClasse() async {
    setState(() => _isLoading = true);
    try {
      var doc = await FirebaseFirestore.instance
          .collection('classes')
          .doc(widget.classeId)
          .get();

      if (doc.exists) {
        _classe = Classe.fromFirestore(doc);
        _intituleController.text = _classe!.intitule;
        _volumeHoraireController.text = _classe!.volumeHoraire.toString();
      }
    } catch (e) {
      print('Error fetching class: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Class Details')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_classe == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Class Details')),
        body: const Center(child: Text('Class not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Class' : 'Class Details'),
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
                TextFormField(
                  controller: _intituleController,
                  decoration: const InputDecoration(labelText: 'Intitulé'),
                  readOnly: !_isEditing,
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter a title' : null,
                ),
                TextFormField(
                  controller: _volumeHoraireController,
                  decoration:
                      const InputDecoration(labelText: 'Volume Horaire'),
                  keyboardType: TextInputType.number,
                  readOnly: !_isEditing,
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter hourly volume' : null,
                ),
                const SizedBox(height: 20),
                if (_isEditing)
                  ElevatedButton(
                    onPressed: _submitUpdate,
                    child: const Text('Update Class'),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submitUpdate() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      await FirebaseFirestore.instance
          .collection('classes')
          .doc(widget.classeId)
          .update({
        'intitule': _intituleController.text,
        'volume_horaire': int.parse(_volumeHoraireController.text),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Class updated successfully')),
      );

      widget.onUpdated();
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update class: $e')),
      );
    }
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text('Are you sure you want to delete this class?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog first
                _deleteClasse(); // Then call delete class
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteClasse() async {
    try {
      await FirebaseFirestore.instance
          .collection('classes')
          .doc(widget.classeId)
          .delete();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Class deleted successfully')),
      );

      widget.onUpdated();
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete class: $e')),
      );
    }
  }
}
