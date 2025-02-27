import 'package:flutter/material.dart';

class SettingsForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController usernameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController phoneController;
  final VoidCallback onSave;

  const SettingsForm({
    required this.formKey,
    required this.usernameController,
    required this.emailController,
    required this.passwordController,
    required this.phoneController,
    required this.onSave,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: formKey,
        child: Column(
          children: [
            TextFormField(
              controller: usernameController,
              decoration: const InputDecoration(labelText: "Username"),
              validator: (value) => value!.isEmpty ? "Enter a username" : null,
            ),
            TextFormField(
              controller: emailController,
              decoration: const InputDecoration(labelText: "Email"),
              validator: (value) => value!.isEmpty ? "Enter an email" : null,
            ),
            TextFormField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: "Password"),
              obscureText: true,
              validator: (value) => value!.isEmpty ? "Enter a password" : null,
            ),
            TextFormField(
              controller: phoneController,
              decoration: const InputDecoration(labelText: "Phone"),
              validator: (value) =>
                  value!.isEmpty ? "Enter a phone number" : null,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
                onPressed: onSave, child: const Text("Save Changes")),
          ],
        ),
      ),
    );
  }
}
