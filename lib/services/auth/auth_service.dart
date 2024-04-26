import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class AuthService {
  // instance of auth
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;

  // get current user
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // sign in
  Future<UserCredential> signInWithEmailPassword(String email, password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // save user info in a separate doc
      _fireStore.collection("Users").doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'email': email,
      });

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  // sign up
  Future<UserCredential> signUpWithEmailPassword(
      String email, password, name) async {
    try {
      // create user
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // save user info in a separate doc
      _fireStore.collection("Users").doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'email': email,
        'displayName': name,
      });

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  // sign out
  Future<void> signOut() async {
    return await _auth.signOut();
  }

  // Upload profile photo to Firebase Storage
  Future<String> uploadProfilePhoto(String uid, File imageFile) async {
    try {
      final storageRef = firebase_storage.FirebaseStorage.instance
          .ref()
          .child('profile_photos')
          .child(uid)
          .child('${DateTime.now().millisecondsSinceEpoch}.jpg');

      await storageRef.putFile(imageFile);

      final downloadURL = await storageRef.getDownloadURL();
      // Update user's profile with the download URL
      await FirebaseAuth.instance.currentUser?.updatePhotoURL(downloadURL);

      return downloadURL;
    } catch (e) {
      throw Exception('Error uploading profile photo: $e');
    }
  }

  // Update user's name
  Future<void> updateUserName(String newName) async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        await user.updateDisplayName(newName);
      }
    } catch (e) {
      throw Exception('Error updating user name: $e');
    }
  }
}
