import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:login_and_signup/ui_helper.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  TextEditingController emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Forgot Passsword'),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'We will send you reset link to this email',
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
            UiHelper.CustomTextField(
                emailController, 'Enter Email', Icons.mail, false),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
              onPressed: () {
                _resetPassword(emailController.text.toString());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                minimumSize: const Size(300, 50),
              ),
              child: const Text(
                'Reset Password',
                style: TextStyle(color: Colors.white),
              ),
            )
          ],
        ),
      ),
    );
  }

  _resetPassword(String email) async {
    if (email.isNotEmpty) {
      try {
        await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password reset email sent successfully.'),
          ),
        );
      } on FirebaseAuthException catch (ex) {
        String errorMessage = "An error occurred";
        if (ex.code == 'user-not-found') {
          errorMessage = "No user found with this email";
        } else if (ex.code == 'invalid-email') {
          errorMessage = "Invalid email address";
        }
        UiHelper.CustomAlertBox(context, errorMessage);
      }
    } else {
      UiHelper.CustomAlertBox(context, "Email cannot be empty");
    }
  }
}
