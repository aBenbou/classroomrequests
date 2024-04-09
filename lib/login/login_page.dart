import 'package:adv_basics/home/home_page_professeur.dart';
import 'package:adv_basics/home/home_page_securite.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:adv_basics/home/home_page_admin.dart';
import 'package:adv_basics/login/custom_button.dart';
import 'package:adv_basics/login/gradient_container.dart';
import 'package:google_fonts/google_fonts.dart';

class LogInScreen extends StatefulWidget {
  const LogInScreen({super.key});

  @override
  State<LogInScreen> createState() {
    return _LogInScreenState();
  }
}

class _LogInScreenState extends State<LogInScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> login() async {
    try {
      // Authenticate using Firebase Authentication
      final UserCredential userCredential =
          await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (userCredential.user != null) {
        print("Authentication successful. UID: ${userCredential.user!.uid}");
        // Fetch additional user details from Firestore
        final docSnapshot = await _firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .get();

        if (!docSnapshot.exists || docSnapshot.data() == null) {
          showLoginError('User not found in database');
          return;
        }

        final category = docSnapshot.data()!['category'];
        print("Retrieved category: $category"); // Debug print
        navigateToCategoryPage(category, userCredential.user!.uid);
      }
    } on FirebaseAuthException catch (e) {
      showLoginError(e.message ?? 'Failed to log in');
    }
  }

  Future<void> navigateBasedOnUserRole(String userId) async {
    final docSnapshot = await _firestore.collection('users').doc(userId).get();

    if (!docSnapshot.exists || docSnapshot.data() == null) {
      showLoginError('User not found in database');
      return;
    }

    final category = docSnapshot.data()!['category'];
    navigateToCategoryPage(category, userId);
  }

  void navigateToCategoryPage(String category, String userId) {
    print("Navigating to page based on category: $category");
    switch (category) {
      case 'administrateur':
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
              builder: (context) => const HomePage(
                    initialPage: 0,
                  )),
        );
        break;
      case 'professeur':
        // Navigate to the ProfessorHomePage with the user ID
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => ProfessorHomePage(
              initialPage: 0,
              userId: userId,
            ),
          ),
        );
        break;
      case 'securite':
        // Navigate to the Securite page
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => SecuriteHomePage(
              initialPage: 0,
              userId: userId,
            ),
          ),
        );
        break;
      default:
        showLoginError('Unknown user category');
    }
  }

  void showLoginError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientContainer(
        colors: const [
          Color.fromARGB(255, 28, 150, 173),
          Color.fromARGB(255, 34, 175, 203)
        ],
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Center(
            child: SingleChildScrollView(child: buildLoginUI()),
          ),
        ),
      ),
    );
  }

  Widget buildLoginUI() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset('assets/images/uir-logo.png', width: 200),
        const SizedBox(height: 30),
        buildTitleText(),
        const SizedBox(height: 30),
        buildEmailField(),
        const SizedBox(height: 20),
        buildPasswordField(),
        const SizedBox(height: 20),
        buildForgotPassword(),
        const SizedBox(height: 20),
        buildLoginButton(),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget buildTitleText() {
    return Text(
      'RSVNow',
      style: GoogleFonts.lato(
          color: const Color.fromARGB(255, 227, 242, 245),
          fontSize: 24,
          fontWeight: FontWeight.bold),
      textAlign: TextAlign.center,
    );
  }

  Widget buildEmailField() {
    return TextFormField(
      controller: emailController,
      decoration: const InputDecoration(
          labelText: 'Email',
          prefixIcon: Icon(Icons.email),
          border: OutlineInputBorder()),
    );
  }

  Widget buildPasswordField() {
    return TextFormField(
      controller: passwordController,
      obscureText: true,
      decoration: const InputDecoration(
          labelText: 'Password',
          prefixIcon: Icon(Icons.lock),
          border: OutlineInputBorder()),
    );
  }

  Widget buildForgotPassword() {
    return InkWell(
      onTap: () {
        // TODO: Implement forgot password logic
      },
      child: const Align(
        alignment: Alignment.centerRight,
        child: Text(
          'Forgot Password?',
          style: TextStyle(
              color: Color.fromARGB(255, 115, 130, 133),
              decoration: TextDecoration.underline,
              fontStyle: FontStyle.italic),
        ),
      ),
    );
  }

  Widget buildLoginButton() {
    return CustomButton(
      answerText: 'Login',
      onTap: login,
      icon: const Icon(Icons.login),
    );
  }
}
