import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:login_and_signup/home_page.dart';
import 'package:login_and_signup/ui_helper.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final GlobalKey<FormState> _formState = GlobalKey();
  TextEditingController userNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool isSigIn = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SignIn Page'),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Form(
          key: _formState,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Signin',
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
              const SizedBox(
                height: 20,
              ),
              UiHelper.CustomTextField(
                  userNameController, 'Username', Icons.person, false),
              UiHelper.CustomTextField(
                  emailController, 'Enter Email', Icons.mail, false),
              UiHelper.CustomTextField(
                  passwordController, 'Enter Password', Icons.password, true),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                onPressed: () {
                  _signIn();
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue, minimumSize: const Size(300, 50)),
                child: isSigIn == true
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                    : const Text(
                        'Signin',
                        style: TextStyle(color: Colors.white),
                      ),
              ),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton.icon(
                icon: const Icon(
                  FontAwesomeIcons.google,
                  color: Colors.white,
                ),
                label: const Text(
                  'Signin with Google',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red, minimumSize: const Size(300, 50)),
                onPressed: () {
                  _signInWithGoogle();
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  _signIn() async {
    if (_formState.currentState!.validate()) {
      setState(() {
        isSigIn = true;
      });

      try {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const Homepage()),
        );
      } on FirebaseAuthException catch (ex) {
        String errorMessage = "An error occurred";
        if (ex.code == 'email-already-in-use') {
          errorMessage = "The account already exists for that email.";
        } else if (ex.code == 'invalid-email') {
          errorMessage = "The email address is not valid.";
        }
        UiHelper.CustomAlertBox(context, errorMessage);
      } finally {
        setState(() {
          isSigIn = false;
        });
      }
    } else {
      UiHelper.CustomAlertBox(context, "All fields are required");
    }
  }

  _signInWithGoogle() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final GoogleSignIn googleSignIn = GoogleSignIn();

    try {
      final GoogleSignInAccount? googleSignInAccount =
          await googleSignIn.signIn();

      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication =
            await googleSignInAccount.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          idToken: googleSignInAuthentication.idToken,
          accessToken: googleSignInAuthentication.accessToken,
        );

        await auth.signInWithCredential(credential);

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const Homepage()),
        );
      }
    } on FirebaseAuthException catch (ex) {
      String errorMessage = "An error occurred";
      if (ex.code == 'account-exists-with-different-credential') {
        errorMessage =
            "An account already exists with the same email address but different sign-in credentials.";
      } else if (ex.code == 'invalid-credential') {
        errorMessage =
            "The supplied auth credential is malformed or has expired.";
      } else if (ex.code == 'operation-not-allowed') {
        errorMessage = "Google sign-in is currently disabled.";
      } else if (ex.code == 'user-disabled') {
        errorMessage =
            "The user account has been disabled by an administrator.";
      } else if (ex.code == 'user-not-found') {
        errorMessage =
            "There is no user record corresponding to this identifier.";
      } else if (ex.code == 'wrong-password') {
        errorMessage =
            "The password is invalid or the user does not have a password.";
      }

      UiHelper.CustomAlertBox(context, errorMessage);
    }
  }
}
