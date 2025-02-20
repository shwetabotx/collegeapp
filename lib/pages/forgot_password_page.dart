import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  ForgotPasswordPageState createState() => ForgotPasswordPageState();
}

class ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController classIdController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool isLoading = false;

  // Function to generate a random password
  String generatePassword() {
    const chars =
        "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    final random = Random();
    return List.generate(10, (index) => chars[random.nextInt(chars.length)])
        .join();
  }

  // Function to send an email
  Future<void> sendEmail(String recipientEmail, String newPassword) async {
    String username = "snehajadejatest01@gmail.com"; // Replace with your email
    String password = "sqag njmr iycz hyjk"; // Replace with your app password

    final smtpServer = gmail(username, password);

    final message = Message()
      ..from = Address(username, 'College App')
      ..recipients.add(recipientEmail)
      ..subject = 'Password Reset'
      ..text =
          'Your new password is: $newPassword\n\nPlease change it after logging in.';

    try {
      await send(message, smtpServer);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("New password sent to email!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to send email: $e")),
      );
    }
  }

  // Function to reset password
  Future<void> resetPassword() async {
    setState(() {
      isLoading = true;
    });

    String email = emailController.text.trim();
    String username = usernameController.text.trim();
    String classId = classIdController.text.trim().toUpperCase();

    try {
      QuerySnapshot query = await _firestore
          .collection('classes')
          .doc(classId)
          .collection('students')
          .where('username', isEqualTo: username)
          .where('email', isEqualTo: email) // Ensure email matches
          .get();

      if (query.docs.isNotEmpty) {
        var docRef = query.docs.first.reference;
        String newPassword = generatePassword();

        // Update password in Firestore
        await docRef.update({'password': newPassword});

        // Send email with new password
        await sendEmail(email, newPassword);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Password reset successful! Check your email.")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  "Email does not exist under this username and classId.")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Forgot Password")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: "Enter your Email"),
            ),
            TextField(
              controller: usernameController,
              decoration:
                  const InputDecoration(labelText: "Enter your Username"),
            ),
            TextField(
              controller: classIdController,
              decoration:
                  const InputDecoration(labelText: "Enter your Class ID"),
            ),
            const SizedBox(height: 20),
            isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: resetPassword,
                    child: const Text("Reset Password"),
                  ),
          ],
        ),
      ),
    );
  }
}
