import 'package:adv_basics/home/home_page_admin.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddUser extends StatefulWidget {
  const AddUser({super.key});

  @override
  State<AddUser> createState() {
    return _AddUserState();
  }
}

class _AddUserState extends State<AddUser> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  String _selectedCategory = 'administrateur';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add User'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => const HomePage(initialPage: 5),
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
                _buildNameField('Nom', _nomController),
                const SizedBox(height: 16),
                _buildNameField('Prenom', _prenomController),
                const SizedBox(height: 36),
                Text(
                  'Category',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                _buildCategoryRadioList(),
                const SizedBox(height: 20),
                Center(
                  child: _buildSubmitButton(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNameField(String label, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      validator: (value) => value!.isEmpty ? 'Please enter $label' : null,
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: _submitUser,
      child: const Text('Submit User'),
    );
  }

  Widget _buildCategoryRadioList() {
    return Column(
      children: ['administrateur', 'professeur', 'securite']
          .map((category) => RadioListTile<String>(
                title: Text(category, style: const TextStyle(fontSize: 16)),
                value: category,
                dense: true,
                groupValue: _selectedCategory,
                onChanged: (newValue) =>
                    setState(() => _selectedCategory = newValue!),
              ))
          .toList(),
    );
  }

  void _submitUser() async {
    if (!_formKey.currentState!.validate()) return;

    String email = '${_prenomController.text}.${_nomController.text}@uir.ac.ma';
    String password = '123456'; // Default password

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'nom': _nomController.text,
        'prenom': _prenomController.text,
        'category': _selectedCategory,
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User successfully added')),
      );

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomePage(initialPage: 5)),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add user: $e')),
      );
    }
  }
}
