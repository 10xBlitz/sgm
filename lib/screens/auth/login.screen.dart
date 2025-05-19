import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sgm/screens/auth/awaiting_approval.screen.dart';
import 'package:sgm/screens/main.screen.dart';
import 'package:sgm/services/auth.service.dart';
import 'package:sgm/services/global_manager.service.dart';
import 'package:sgm/theme/theme.dart';

class LoginScreen extends StatefulWidget {
  static const routeName = "/login";
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController(
    text: kDebugMode ? "business+admin@10xblitz.com" : null,
  );
  final _phoneNumberController = TextEditingController();
  final _passwordController = TextEditingController(
    text: kDebugMode ? "qwerqwer" : null,
  );
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _isRegistering = false;
  final globalManager = GlobalManagerService();
  final authService = AuthService();

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneNumberController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_validateInputs()) return;
    setState(() {
      _isLoading = true;
    });
    try {
      final success = await authService.login(
        _emailController.text.trim(),
        _passwordController.text,
      );
      if (!mounted) return;
      if (!success) {
        globalManager.showSnackbarError(context, "Invalid email or password");
        return;
      }

      // conditional
      // if user is approved
      final hasProfile = await authService.hasProfileLoaded;
      if (hasProfile == false) {
        final newProfileCreated = await authService.createProfile(
          name: _fullNameController.text.trim(),
          email: _emailController.text.trim(),
          phone: _phoneNumberController.text.trim(),
        );
        if (!mounted) return;
        if (newProfileCreated == null) {
          globalManager.showSnackbarError(context, "Error creating profile.");
          return;
        }
        context.go(AwaitingApprovalScreen.routeName);
        return;
      }

      if (!mounted) return;
      if (hasProfile == null) {
        globalManager.showSnackbar(context, "Profile loading error.");
        return;
      }

      if (!authService.isConfirmedEmail) {
        globalManager.showSnackbarError(context, "Please confirm your email!");
        if (!mounted) return;
        context.go(AwaitingApprovalScreen.routeName);
        return;
      }
      if (!authService.isApproved) {
        globalManager.showSnackbarError(context, "Please wait for approval");
        if (!mounted) return;
        context.go(AwaitingApprovalScreen.routeName);
        return;
      }

      // Navigate to main screen after successful login
      context.go(MainScreen.routeName);
    } catch (e) {
      if (mounted) {
        globalManager.showSnackbarError(
          context,
          "Error logging in: ${e.toString()}",
        );
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
    });
    try {
      final success = await authService.register(
        _emailController.text.trim(),
        _passwordController.text,
      );
      if (!mounted) return;
      if (!success) {
        globalManager.showSnackbarError(
          context,
          "Could not register with these credentials",
        );
        return;
      }

      // Insert into public.users table

      globalManager.showSnackbar(
        context,
        'Registration successful! Please check your email to confirm your account.',
      );
      setState(() {
        _isRegistering = false;
      });

      debugPrint("Auto login");

      await authService.login(
        _emailController.text.trim(),
        _passwordController.text,
      );
      if ((await authService.hasProfileLoaded) == null) {
        if (!mounted) return;
        // means there is an error.
        globalManager.showSnackbarError(context, "Something went wrong.");
        return;
      }
      await authService.createProfile(
        name: _fullNameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneNumberController.text.trim(),
      );
      if (!mounted) return;
      context.go(AwaitingApprovalScreen.routeName);
    } catch (e) {
      if (mounted) {
        globalManager.showSnackbarError(
          context,
          "Error registering: ${e.toString()}",
        );
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
      globalManager.showSnackbarError(
        context,
        "Please enter a valid email address",
      );
      return false;
    }
    if (_passwordController.text.isEmpty ||
        _passwordController.text.length < 6) {
      globalManager.showSnackbarError(
        context,
        "Password must be at least 6 characters",
      );
      return false;
    }
    return true;
  }

  bool _passwordMatchCheck() {
    if (_passwordController.text != _confirmPasswordController.text) {
      globalManager.showSnackbarError(context, 'Passwords do not match');
      return false;
    }
    return true;
  }

  bool _validFullName() {
    if (_fullNameController.text.trim().isEmpty) {
      globalManager.showSnackbarError(context, 'Full name cannot be empty');
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isRegistering ? "Registration" : "Login",
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontSize: 24),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),
              const SizedBox(height: 8),
              Image.asset('assets/images/logo.png', height: 100, width: 100),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  "SEOUL GUIDE MEDICAL",
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                _isRegistering ? "Create an Account" : "Welcome Back",
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              if (_isRegistering) ...[
                TextField(
                  controller: _fullNameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    hintText: 'Enter your full name',
                    prefixIcon: Icon(Icons.person),
                  ),
                  enabled: !_isLoading,
                ),
                const SizedBox(height: 16),
              ],
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  hintText: 'Enter your email',
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                autofillHints: const [AutofillHints.email],
                enabled: !_isLoading,
              ),
              const SizedBox(height: 16),
              if (_isRegistering) ...[
                TextField(
                  controller: _phoneNumberController,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    hintText: 'Enter your phone number',
                    prefixIcon: Icon(Icons.phone),
                  ),
                  keyboardType: TextInputType.phone,
                  enabled: !_isLoading,
                ),
                const SizedBox(height: 16),
              ],
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  hintText: 'Enter your password',
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
                autocorrect: false,
                autofillHints: const [AutofillHints.password],
                enabled: !_isLoading,
              ),
              const SizedBox(height: 16),
              if (_isRegistering) ...[
                TextField(
                  controller: _confirmPasswordController,
                  decoration: const InputDecoration(
                    labelText: 'Confirm Password',
                    hintText: 'Re-enter your password',
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
              FilledButton(
                onPressed:
                    _isLoading ? null : (_isRegistering ? _register : _login),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child:
                    _isLoading
                        ? SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator.adaptive(
                            strokeWidth: 2,
                            backgroundColor:
                                Theme.of(context).colorScheme.onPrimary,
                          ),
                        )
                        : Text(_isRegistering ? 'REGISTER' : 'LOGIN'),
              ),
              const SizedBox(height: 32),
              TextButton(
                onPressed:
                    _isLoading
                        ? null
                        : () {
                          setState(() {
                            _isRegistering = !_isRegistering;
                          });
                        },
                child:
                    _isRegistering
                        ? Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: 'Already have an account?   ',
                                style: TextStyle(
                                  color:
                                      Theme.of(
                                        context,
                                      ).colorScheme.onSecondaryContainer,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                              TextSpan(
                                text: 'Login',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontFamily:
                                      MaterialTheme
                                          .fontFamilyString
                                          .playfairDisplay,
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                        )
                        : Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: 'Need an account?   ',
                                style: TextStyle(
                                  color:
                                      Theme.of(
                                        context,
                                      ).colorScheme.onSecondaryContainer,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                              TextSpan(
                                text: 'Register',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontFamily:
                                      MaterialTheme
                                          .fontFamilyString
                                          .playfairDisplay,
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),
              ),
              SizedBox(height: 64),
            ],
          ),
        ),
      ),
    );
  }
}
