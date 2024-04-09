import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:adv_basics/home/home_page_admin.dart';

class AddClassroom extends StatefulWidget {
  const AddClassroom({super.key});

  @override
  State<AddClassroom> createState() {
    return _AddClassroomState();
  }
}

class _AddClassroomState extends State<AddClassroom> {
  final _formKey = GlobalKey<FormState>();
  final _numeroController = TextEditingController();
  final _etageController = TextEditingController();
  final _batimentController = TextEditingController();
  String _selectedType = 'E';
  String _previewText = '';

  @override
  void initState() {
    super.initState();
    _numeroController.addListener(_updatePreview);
    _etageController.addListener(_updatePreview);
    _batimentController.addListener(_updatePreview);
  }

  @override
  void dispose() {
    _numeroController.removeListener(_updatePreview);
    _etageController.removeListener(_updatePreview);
    _batimentController.removeListener(_updatePreview);
    _numeroController.dispose();
    _etageController.dispose();
    _batimentController.dispose();
    super.dispose();
  }

  void _updatePreview() {
    String etage = _selectedType == 'Amphi' ? '' : _etageController.text;
    String numero = _selectedType == 'Amphi'
        ? _numeroController.text
        : _numeroController.text.padLeft(2, '0');
    String batiment = _batimentController.text;

    setState(() {
      _previewText = "$_selectedType ${etage + numero} Bat $batiment";
    });
  }

  List<Widget> _buildTypeRadioList() {
    return ['E', 'TP', 'Amphi'].map((type) {
      return RadioListTile<String>(
        title: Text(type),
        value: type,
        groupValue: _selectedType,
        onChanged: (String? newValue) {
          setState(() {
            _selectedType = newValue!;
            _updatePreview();
          });
        },
        dense: true,
      );
    }).toList();
  }

  void _submitClassroom() async {
    if (!_formKey.currentState!.validate()) return;

    String formattedNumero = _numeroController.text.padLeft(2, '0');
    String etage = _selectedType == 'Amphi' ? '0' : _etageController.text;

    try {
      await FirebaseFirestore.instance.collection('classrooms').add({
        'type': _selectedType,
        'etage': etage,
        'numero': formattedNumero,
        'batiment': _batimentController.text,
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Classroom successfully added')),
      );

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomePage(initialPage: 3)),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add classroom: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Classroom'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => const HomePage(initialPage: 3),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Type',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.normal)),
                ..._buildTypeRadioList(),
                if (_selectedType != 'Amphi')
                  TextFormField(
                    controller: _etageController,
                    decoration: const InputDecoration(labelText: 'Etage'),
                    keyboardType: TextInputType.number,
                    validator: (value) =>
                        value!.isEmpty ? 'Please enter etage' : null,
                  ),
                TextFormField(
                  controller: _numeroController,
                  decoration: const InputDecoration(labelText: 'Numero'),
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter numero' : null,
                ),
                TextFormField(
                  controller: _batimentController,
                  decoration: const InputDecoration(labelText: 'Batiment'),
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter batiment' : null,
                ),
                const SizedBox(height: 20),
                Text('Preview: $_previewText'),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: _submitClassroom,
                    child: const Text('Submit Classroom'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
