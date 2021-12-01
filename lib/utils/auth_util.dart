import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

void startAuthListener() {
  FirebaseAuth.instance.authStateChanges().listen((User? user) {
    if (user == null) {
      Get.offAllNamed("/login", predicate: (_) => false);
    } else {
      Get.log('User is signed in!');
      Get.offAllNamed("/dashboard", predicate: (_) => false);
    }
  });
}
