import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sgm/screens/main.screen.dart';
import 'package:sgm/services/auth_service.dart';
import 'package:sgm/utils/show_snackbar.dart';

class LoginScreen extends StatefulWidget {
  static const routeName = "/login";
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _isRegistering = false;
  String? _errorMessage;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_validateInputs()) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final success = await authService.login(
        _emailController.text.trim(),
        _passwordController.text,
      );
      debugPrint("Login attempt with email: ${_emailController.text.trim()}");
      if (!mounted) return;
      if (!success) {
        setState(() {
          _errorMessage = "Invalid email or password";
        });
        return;
      }
      // Navigate to main screen after successful login
      context.go(MainScreen.routeName);
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = "Error logging in: ${e.toString()}";
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _register() async {
    if (!_validateInputs()) return;
    if (!_passwordMatchCheck()) return;
    if (!_validFullName()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final success = await authService.register(
        _emailController.text.trim(),
        _passwordController.text,
      );
      if (!mounted) return;
      if (!success) {
        setState(() {
          _errorMessage = "Could not register with these credentials";
        });
        return;
      }
      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(
      //     content: Text(
      //       'Registration successful! Please check your email to confirm your account.',
      //     ),
      //     duration: Duration(seconds: 5),
      //   ),
      // );

      showSnackbar(
        context,
        'Registration successful! Please check your email to confirm your account.',
      );
      setState(() {
        _isRegistering = false;
      });
      // TODO redirect to Email Confirmation Screen
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = "Error registering: ${e.toString()}";
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  bool _validateInputs() {
    if (_emailController.text.trim().isEmpty ||
        !_emailController.text.contains('@')) {
      setState(() {
        _errorMessage = "Please enter a valid email address";
      });
      return false;
    }
    if (_passwordController.text.isEmpty ||
        _passwordController.text.length < 6) {
      setState(() {
        _errorMessage = "Password must be at least 6 characters";
      });
      return false;
    }
    return true;
  }

  bool _passwordMatchCheck() {
    if (_passwordController.text != _confirmPasswordController.text) {
      showSnackbar(context, 'Passwords do not match');
      return false;
    }
    return true;
  }

  bool _validFullName() {
    if (_fullNameController.text.trim().isEmpty) {
      showSnackbar(context, 'Full name cannot be empty');
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isRegistering ? "Registration" : "Login")),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Logo or branding here if needed
              const SizedBox(height: 32),

              Image.asset('assets/images/logo.png', height: 100, width: 100),
              const SizedBox(height: 32),

              // Title
              Text(
                _isRegistering ? "Create an Account" : "Welcome Back",
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontFamily: 'NotoSansKR',
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Error message
              if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(color: Colors.red.shade800),
                    textAlign: TextAlign.center,
                  ),
                ),
              if (_errorMessage != null) const SizedBox(height: 16),

              if (_isRegistering) ...[
                // Show full name if registering
                TextField(
                  controller: _fullNameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    hintText: 'Enter your full name',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                ),

                const SizedBox(height: 16),
              ],

              // Email field
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  hintText: 'Enter your email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                autofillHints: const [AutofillHints.email],
                enabled: !_isLoading,
              ),
              const SizedBox(height: 16),

              // Password field
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  hintText: 'Enter your password',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
                autocorrect: false,
                autofillHints: const [AutofillHints.password],
                enabled: !_isLoading,
              ),
              const SizedBox(height: 16),

              // Show Confirm Password when registering
              if (_isRegistering) ...[
                TextField(
                  controller: _confirmPasswordController,
                  decoration: const InputDecoration(
                    labelText: 'Confirm Password',
                    hintText: 'Re-enter your password',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                  ),
                  obscureText: true,
                  autocorrect: false,
                  autofillHints: const [AutofillHints.password],
                  enabled: !_isLoading,
                ),
                const SizedBox(height: 16),
              ],
              const SizedBox(height: 16),
              // Login/Register button
              ElevatedButton(
                onPressed:
                    _isLoading ? null : (_isRegistering ? _register : _login),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child:
                    _isLoading
                        ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : Text(_isRegistering ? 'Register' : 'Login'),
              ),
              const SizedBox(height: 16),

              // Toggle between login and register
              TextButton(
                onPressed:
                    _isLoading
                        ? null
                        : () {
                          setState(() {
                            _isRegistering = !_isRegistering;
                            _errorMessage = null;
                          });
                        },
                child: Text(
                  _isRegistering
                      ? 'Already have an account? Login'
                      : 'Need an account? Register',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
