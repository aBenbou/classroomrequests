import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:adv_basics/model/user.dart';

class ProfilView extends StatefulWidget {
  final String userId;

  const ProfilView({super.key, required this.userId});

  @override
  State<ProfilView> createState() => _ProfilViewState();
}

class _ProfilViewState extends State<ProfilView> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _categoryController = TextEditingController();
  final _emailController = TextEditingController();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isEditing = false;
  bool _isLoading = true;
  User? _user;

  @override
  void initState() {
    super.initState();
    _fetchUser();
  }

  Future<void> _fetchUser() async {
    setState(() => _isLoading = true);
    try {
      var firebaseUser = auth.FirebaseAuth.instance.currentUser;
      _emailController.text = firebaseUser?.email ?? 'Not Available';

      var doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .get();

      if (doc.exists) {
        _user = User.fromFirestore(doc);
        _nomController.text = _user!.nom;
        _prenomController.text = _user!.prenom;
        _categoryController.text = _user!.category;
      }
    } catch (e) {
      print('Error fetching user: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updatePassword() async {
    if (_formKey.currentState!.validate()) {
      if (_newPasswordController.text == _confirmPasswordController.text) {
        try {
          var user = auth.FirebaseAuth.instance.currentUser;
          var credentials = auth.EmailAuthProvider.credential(
            email: user!.email!,
            password: _oldPasswordController.text,
          );
          await user.reauthenticateWithCredential(credentials);
          await user.updatePassword(_newPasswordController.text);
          _showSnackBar('Password updated successfully');
        } catch (e) {
          _showSnackBar('Failed to update password: $e');
        }
      } else {
        _showSnackBar('New password and confirm password do not match');
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profil')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profil')),
        body: const Center(child: Text('User not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 20),
              const CircleAvatar(
                radius: 50, // Placeholder for profile picture
                child: Icon(Icons.person, size: 50),
              ),
              const SizedBox(height: 20),
              Text('${_user!.nom} ${_user!.prenom}',
                  style: Theme.of(context).textTheme.titleLarge),
              Text(_user!.category,
                  style: Theme.of(context).textTheme.titleMedium),
              const Divider(),
              ListTile(
                title: const Text('Email'),
                subtitle: Text(_emailController.text),
              ),
              _isEditing
                  ? _buildPasswordChangeForm()
                  : _buildPasswordListTile(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordChangeForm() {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            _buildPasswordField('Current Password', _oldPasswordController),
            _buildPasswordField('New Password', _newPasswordController),
            _buildPasswordField('Confirm Password', _confirmPasswordController),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updatePassword,
              child: const Text('Update Password'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordListTile() {
    return ListTile(
      title: const Text('Password'),
      subtitle: const Text('********'),
      trailing: ElevatedButton(
        onPressed: () => setState(() => _isEditing = true),
        child: const Text('Change Password'),
      ),
    );
  }

  Widget _buildPasswordField(String label, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      obscureText: true,
      validator: (value) {
        if (value!.isEmpty) {
          return 'Please enter $label';
        }
        if (label == 'Confirm Password' &&
            value != _newPasswordController.text) {
          return 'Passwords do not match';
        }
        return null;
      },
    );
  }
}
