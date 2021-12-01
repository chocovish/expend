import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

Future<UserCredential?> _signInWithGoogle() async {
  // Trigger the authentication flow
  final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
  if (googleUser == null) return null;
  // Obtain the auth details from the request
  final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

  // Create a new credential
  final credential = GoogleAuthProvider.credential(
    accessToken: googleAuth.accessToken,
    idToken: googleAuth.idToken,
  );

  // Once signed in, return the UserCredential
  return await FirebaseAuth.instance.signInWithCredential(credential);
}

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final controller = RoundedLoadingButtonController();
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: [Colors.greenAccent.shade200, Colors.lightBlueAccent],
                begin: Alignment.bottomLeft,
                end: Alignment.topRight)),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Expense.",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 50,
                    color: Colors.yellowAccent),
              ),
              const SizedBox(height: 20),
              RoundedLoadingButton(
                  controller: controller,
                  onPressed: () async {
                    _signInWithGoogle().catchError((e) {
                      Get.log(e.toString(), isError: true);
                      controller.error();
                    }).then((x) async {
                      if (x?.user == null) {
                        controller.error();
                        await Future.delayed(const Duration(seconds: 3));
                        controller.stop();
                      } else {
                        controller.success();
                      }
                      Get.log(x?.user?.displayName ?? "user is null");
                    });
                  },
                  child: const Text(
                    "Sign In With Google",
                    textScaleFactor: 1.2,
                  ))
            ],
          ),
        ),
      ),
    );
  }
}
