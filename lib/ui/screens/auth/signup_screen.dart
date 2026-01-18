import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:daily_coding_questions_app/providers/auth_provider.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  final _confirmPassController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus();

      final auth = Provider.of<AuthProvider>(context, listen: false);

      bool success = await auth.signUp(
        _emailController.text.trim(),
        _passController.text.trim(),
      );

      if (success && mounted) {
        // Pop back to root (AuthWrapper will redirect to Home)
        Navigator.pop(context);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(auth.errorMessage ?? "Signup failed"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Account")),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Email
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: "Email",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (v) => v!.isEmpty ? "Email is required" : null,
                ),
                const SizedBox(height: 16),

                // Password
                TextFormField(
                  controller: _passController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: "Password",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  validator: (v) => v!.length < 6 ? "Min 6 chars" : null,
                ),
                const SizedBox(height: 16),

                // Confirm Password
                TextFormField(
                  controller: _confirmPassController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: "Confirm Password",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  validator: (v) {
                    if (v != _passController.text)
                      return "Passwords do not match";
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Signup Button
                Consumer<AuthProvider>(
                  builder: (context, auth, _) {
                    return auth.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : FilledButton(
                            onPressed: _handleSignup,
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Text("SIGN UP"),
                          );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
