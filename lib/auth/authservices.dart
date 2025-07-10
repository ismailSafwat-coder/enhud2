import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Authservices {
  // Get instance of firebase auth
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user
  User? getcurrentuser() {
    return _firebaseAuth.currentUser;
  }

  Future<void> updatevalue(String field, String value) async {
    try {
      // Get current authenticated user
      User? user = FirebaseAuth.instance.currentUser;
      String uid = user!.uid;

      // Check if user is logged in
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        field: value,
      });
    } catch (e) {
      print("Error saving user data: $e");
      rethrow;
    }
  }

  Future<void> addUserInfoToFirestore(
    String? name,
    String acdamic,
    String gender,
  ) async {
    try {
      // Get current authenticated user
      User? user = FirebaseAuth.instance.currentUser;
      String uid = user!.uid;
      String url =
          "https://media.istockphoto.com/id/1337144146/vector/default-avatar-profile-icon-vector.jpg?s=612x612&w=0&k=20&c=BIbFwuv7FxTWvh5S3vB6bkT0Qv8Vn8N5Ffseq84ClGI=";

      // Check if user is logged in
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'uid': uid,
        "gender": gender,
        'academicYear': acdamic,
        'email': user.email,
        'name': user.displayName ?? name,
        'photoURL': user.photoURL ?? url,
        'createdAt': FieldValue.serverTimestamp(),
        // Add other fields as needed
      });
    } catch (e) {
      print("Error saving user data: $e");
      rethrow;
    }
  }

  // Sign in
  Future<String> signin({
    required String email,
    required String password,
    required BuildContext context, // Added context for showing dialogs
  }) async {
    String res = 'Some errors occurred';
    try {
      if (email.isNotEmpty && password.isNotEmpty) {
        await _firebaseAuth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        res = 'succeed';
      } else {
        res = 'Please fill in all the fields';
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        _showErrorDialog(context, 'No user found for that email.');
      } else if (e.code == 'wrong-password') {
        _showErrorDialog(context, 'Wrong password provided for that user.');
      } else {
        _showErrorDialog(context, e.message ?? 'An unknown error occurred.');
      }
    } catch (e) {
      res = e.toString();
      _showErrorDialog(context, res);
    }
    return res;
  }

  // Sign in with Google
  Future<String> signinWithGoogle(BuildContext context) async {
    String res = 'Some errors occurred';
    try {
      await _googleSignIn.signOut();
      // Start the Google sign-in process
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // The user canceled the sign-in
        return 'Sign-in canceled by user';
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google [UserCredential]
      await _firebaseAuth.signInWithCredential(credential);

      // If everything is successful
      res = 'success';
    } on FirebaseAuthException catch (e) {
      res = e.message ?? 'An error occurred during Google Sign-In.';
      _showErrorDialog(context, res);
    } catch (e) {
      res = e.toString();
      _showErrorDialog(context, res);
      print(e.toString());
    }
    return res;
  }

  // Sign up
  Future<String> signup(
      String email, String password, BuildContext context) async {
    String res = 'Some errors occurred';
    try {
      await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      res = 'succeed';
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        _showErrorDialog(context, 'The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        _showErrorDialog(context, 'The account already exists for that email.');
      } else {
        _showErrorDialog(context, e.message ?? 'An unknown error occurred.');
      }
    } catch (e) {
      _showErrorDialog(context, e.toString());
      res = e.toString();
    }
    return res;
  }

  // Sign out
  Future<void> singout() async {
    return await _firebaseAuth.signOut();
  }

  //facebook
  Future<String> signInWithFacebook() async {
    try {
      await FacebookAuth.instance.logOut();
      // Trigger the sign-in flow
      final LoginResult loginResult = await FacebookAuth.instance.login();

      if (loginResult.status == LoginStatus.success) {
        // Create a credential from the access token
        final OAuthCredential facebookAuthCredential =
            FacebookAuthProvider.credential(
                loginResult.accessToken!.tokenString);

        // Sign in to Firebase with the Facebook user credential
        await _auth.signInWithCredential(facebookAuthCredential);

        return 'success';
      } else if (loginResult.status == LoginStatus.cancelled) {
        return 'Login cancelled by user.';
      } else {
        return 'Facebook login failed: ${loginResult.message}';
      }
    } catch (e) {
      return 'Error: ${e.toString()}';
    }
  }

  // Show error dialog
  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
