import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sgm/services/auth.service.dart';
import 'package:sgm/services/global_manager.service.dart';
import 'package:sgm/widgets/user_avatar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import 'package:path/path.dart' as path;

class UserProfileUpdateScreen extends StatefulWidget {
  static const routeName = '/user-profile-update';
  const UserProfileUpdateScreen({super.key});

  @override
  State<UserProfileUpdateScreen> createState() =>
      _UserProfileUpdateScreenState();
}

class _UserProfileUpdateScreenState extends State<UserProfileUpdateScreen> {
  final _fullNameController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();

    debugPrint('Current user profile: ${AuthService().currentUserProfile}');

    _fullNameController.text = AuthService().currentUserProfile?.name ?? '';
    _phoneNumberController.text =
        AuthService().currentUserProfile?.phoneNumber ?? '';
    _emailController.text = AuthService().currentUserProfile?.email ?? '';
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneNumberController.dispose();
    _emailController.dispose();

    super.dispose();
  }

  _updateProfile() async {
    setState(() {
      _isLoading = true;
    });
    await AuthService().updateProfile(
      fullName: _fullNameController.text,
      phoneNumber: _phoneNumberController.text,
      email: _emailController.text,
    );
    if (!mounted) return;
    GlobalManagerService().showSnackbar(
      context,
      'Profile updated successfully!',
    );
    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });
  }

  _updatePhoto() async {
    setState(() {
      _isUploading = true;
    });

    try {
      // Pick image using image_picker
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image == null) {
        setState(() {
          _isUploading = false;
        });
        return;
      }

      // Get current user ID
      final String? userId = AuthService().currentUser?.id;
      if (userId == null) {
        if (!mounted) return;
        GlobalManagerService().showSnackbarError(
          context,
          'User not authenticated',
        );
        setState(() {
          _isUploading = false;
        });
        return;
      }

      // Create a unique filename using timestamp
      final String fileExt = path.extension(image.path);
      final String fileName =
          '$userId-${DateTime.now().millisecondsSinceEpoch}$fileExt';
      final String filePath = '$userId/$fileName';

      // Read file as bytes
      final File file = File(image.path);
      final fileBytes = await file.readAsBytes();

      // Upload to Supabase storage
      await Supabase.instance.client.storage
          .from('profile')
          .uploadBinary(
            // filePath,
            '$userId/$fileName',
            fileBytes,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
          );

      // Get public URL of the uploaded image
      final String imageUrl = Supabase.instance.client.storage
          .from('profile')
          .getPublicUrl(filePath);

      // Update user profile with new image URL
      await AuthService().updateProfileImage(imageUrl);

      // Refresh profile data
      await AuthService().loadProfile();

      if (!mounted) return;
      GlobalManagerService().showSnackbar(
        context,
        'Profile image updated successfully!',
      );
    } catch (e) {
      if (!mounted) return;
      GlobalManagerService().showSnackbarError(
        context,
        'Failed to update profile image: ${e.toString()}',
      );
    }

    setState(() {
      _isUploading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Update Profile',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 32),
            InkWell(
              onTap: _isUploading ? null : _updatePhoto,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: UserAvatar(
                              imageUrl:
                                  AuthService()
                                      .currentUserProfile
                                      ?.profileImage,
                              radius: 80,
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: CircleAvatar(
                              radius: 28,
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.surfaceContainerHigh.withAlpha(200),
                              child: Icon(
                                Icons.camera_alt,
                                size: 32,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      // Outlined Contaier
                      FilledButton(
                        onPressed: _isUploading ? null : _updatePhoto,
                        child:
                            _isUploading
                                ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                                : Text("Update Profile Image"),
                      ),
                      SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
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
                  TextField(
                    controller: _emailController,
                    readOnly: true,
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
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: _isLoading ? null : _updateProfile,
                    child:
                        _isLoading
                            ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                            : Text('UPDATE'),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
