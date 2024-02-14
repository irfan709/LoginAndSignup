import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:login_and_signup/forgot_password.dart';
import 'package:login_and_signup/home_page.dart';
import 'package:login_and_signup/signin_page.dart';
import 'package:login_and_signup/ui_helper.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formState = GlobalKey();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool isLoggedIn = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login Page'),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Form(
          key: _formState,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Login',
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 20,
              ),
              UiHelper.CustomTextField(
                  emailController, 'Enter Email', Icons.mail, false),
              UiHelper.CustomTextField(
                  passwordController, 'Username', Icons.password, true),
              const SizedBox(
                height: 20,
              ),
              TextButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ForgotPasswordPage(),
                        ));
                  },
                  child: const Text('Forgot Password')),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                onPressed: () {
                  _login();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  minimumSize: const Size(300, 50),
                ),
                child: isLoggedIn == true
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                    : const Text(
                        'Login',
                        style: TextStyle(color: Colors.white),
                      ),
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account?"),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SignInPage(),
                          ));
                    },
                    child: const Text('Signup'),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  _login() async {
    if (_formState.currentState!.validate()) {
      setState(() {
        isLoggedIn = true;
      });

      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const Homepage()),
        );
      } on FirebaseAuthException catch (ex) {
        String errorMessage = "An error occurred";
        if (ex.code == 'user-not-found') {
          errorMessage = "No user found with this email";
        } else if (ex.code == 'wrong-password') {
          errorMessage = "Incorrect password";
        }
        UiHelper.CustomAlertBox(context, errorMessage);
      } finally {
        setState(() {
          isLoggedIn = false;
        });
      }
    }
  }
}
