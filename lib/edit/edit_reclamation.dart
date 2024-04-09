import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:adv_basics/model/reclamation.dart';

class EditReclamation extends StatefulWidget {
  final String reclamationId;
  final VoidCallback onUpdated;

  const EditReclamation(
      {super.key, required this.reclamationId, required this.onUpdated});

  @override
  State<EditReclamation> createState() {
    return _EditReclamationState();
  }
}

class _EditReclamationState extends State<EditReclamation> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _descriptionController = TextEditingController();
  bool _isEditing = false;
  bool _isLoading = true;
  Reclamation? _reclamation;

  @override
  void initState() {
    super.initState();
    _fetchReclamation();
  }

  Future<void> _fetchReclamation() async {
    setState(() => _isLoading = true);
    try {
      var doc = await FirebaseFirestore.instance
          .collection('reclamations')
          .doc(widget.reclamationId)
          .get();

      if (doc.exists) {
        _reclamation = await Reclamation.fromFirestore(doc);
        _descriptionController.text = _reclamation!.description;
      }
    } catch (e) {
      print('Error fetching reclamation: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Reclamation Details')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_reclamation == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Reclamation Details')),
        body: const Center(child: Text('Reclamation not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Reclamation' : 'Reclamation Details'),
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
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  readOnly: !_isEditing,
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter a description' : null,
                ),
                const SizedBox(height: 20),
                if (_isEditing)
                  Center(
                    child: ElevatedButton(
                      onPressed: _submitUpdate,
                      child: const Text('Update Reclamation'),
                    ),
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
          .collection('reclamations')
          .doc(widget.reclamationId)
          .update({'description': _descriptionController.text});

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reclamation updated successfully')),
      );

      widget.onUpdated();
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update reclamation: $e')),
      );
    }
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content:
              const Text('Are you sure you want to delete this reclamation?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog first
                _deleteReclamation(); // Then call delete reclamation
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteReclamation() async {
    try {
      await FirebaseFirestore.instance
          .collection('reclamations')
          .doc(widget.reclamationId)
          .delete();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reclamation deleted successfully')),
      );

      widget.onUpdated();
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete reclamation: $e')),
      );
    }
  }
}
