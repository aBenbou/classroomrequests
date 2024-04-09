import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:adv_basics/home/home_page_admin.dart';

class AddClasse extends StatefulWidget {
  const AddClasse({super.key});

  @override
  State<AddClasse> createState() {
    return _AddClasseState();
  }
}

class _AddClasseState extends State<AddClasse> {
  final _formKey = GlobalKey<FormState>();
  final _intituleController = TextEditingController();
  final _volumeHoraireController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Class'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => const HomePage(initialPage: 4),
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
                TextFormField(
                  controller: _intituleController,
                  decoration: const InputDecoration(labelText: 'Intitulé'),
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter a title' : null,
                ),
                TextFormField(
                  controller: _volumeHoraireController,
                  decoration:
                      const InputDecoration(labelText: 'Volume Horaire'),
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter hourly volume' : null,
                ),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: _submitClass,
                    child: const Text('Submit Class'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _submitClass() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      await FirebaseFirestore.instance.collection('classes').add({
        'intitule': _intituleController.text,
        'volume_horaire': int.parse(_volumeHoraireController.text),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Class successfully added')),
      );

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomePage(initialPage: 4)),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add class: $e')),
      );
    }
  }
}
