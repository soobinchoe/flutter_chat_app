import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/services/auth/auth_service.dart';
import 'package:image_picker/image_picker.dart';

class EditProfilePage extends StatefulWidget {
  final String currentEmail;
  final String initialName;

  EditProfilePage(
      {Key? key, required this.currentEmail, required this.initialName})
      : super(key: key);

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  // Text editing controllers
  final TextEditingController _nameController = TextEditingController();
  final AuthService _authService = AuthService();

  // Method to pick an image from the device's gallery
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      // Upload the picked image to Firebase Storage
      final imageUrl = await _authService.uploadProfilePhoto(
        AuthService().getCurrentUser()!.uid,
        File(pickedImage.path),
      );

      setState(() {});
    }
  }

  Widget _buildProfilePhoto(User? currentUser) {
    if (currentUser != null && currentUser.photoURL != null) {
      // If user has a profile photo
      return GestureDetector(
        onTap: _pickImage,
        child: CircleAvatar(
          backgroundImage: NetworkImage(currentUser.photoURL!),
          radius: 30,
        ),
      );
    } else {
      // If user does not have a profile photo, show default logo icon
      return GestureDetector(
        onTap: _pickImage,
        child: Icon(
          Icons.account_circle,
          size: 60,
          color: Theme.of(context).colorScheme.primary,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    _nameController.text =
        widget.initialName; // Set initial name value to the text controller

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text("Edit"),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.grey,
        elevation: 0,
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildProfilePhoto(_authService.getCurrentUser()),

                // Current email
                Text(
                  widget.currentEmail,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 25),

                // Name textfield
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                  ),
                ),
                const SizedBox(height: 10),

                ElevatedButton(
                  onPressed: () {
                    // Call AuthService to update user's name
                    AuthService().updateUserName(_nameController.text);
                    Navigator.pop(context); // Close the edit profile page
                  },
                  child: const Text('Save'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
