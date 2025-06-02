import 'dart:io'; // Для File

import 'package:cached_network_image/cached_network_image.dart'; // Для кэширования аватаров
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart'; // Для выбора изображений
import 'package:sigmail_client/core/navigation/app_router.dart';
import 'package:sigmail_client/presentation/global_blocs/auth/auth_bloc.dart';
import 'package:sigmail_client/presentation/global_blocs/auth/auth_event.dart';
import 'package:sigmail_client/presentation/global_blocs/auth/auth_state.dart';
import 'package:sigmail_client/presentation/blocs/profile/profile_bloc.dart'; // <-- Импорт ProfileBloc
import 'package:sigmail_client/core/injection_container.dart'; // <-- Для sl<ProfileBloc>()

class ProfileScreen extends StatelessWidget { // Можно сделать StatelessWidget и предоставлять ProfileBloc через BlocProvider
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<ProfileBloc>(),
      child: const _ProfileScreenContent(), // Выносим контент в отдельный виджет
    );
  }
}

class _ProfileScreenContent extends StatefulWidget {
  const _ProfileScreenContent();

  @override
  State<_ProfileScreenContent> createState() => _ProfileScreenContentState();
}

class _ProfileScreenContentState extends State<_ProfileScreenContent> {
  File? _selectedImageFile;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 800,
        maxHeight: 800,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImageFile = File(pickedFile.path);
        });
        // Отправляем событие в ProfileBloc
        context.read<ProfileBloc>().add(ProfileEvent.avatarUpdateRequested(imageFile: _selectedImageFile!));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка при выборе изображения: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  void _showImageSourceActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.photo_library, color: Theme.of(context).colorScheme.primary),
                title: Text('Галерея', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
                onTap: () {
                  _pickImage(ImageSource.gallery);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_camera, color: Theme.of(context).colorScheme.primary),
                title: Text('Камера', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
                onTap: () {
                  _pickImage(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: null, // No title
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Градиентный фон
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF6D5FFD),
                  Color(0xFF46A0FC),
                  Color(0xFF23D2B7),
                ],
              ),
            ),
          ),
          BlocListener<ProfileBloc, ProfileState>(
            listener: (context, profileState) {
              profileState.whenOrNull(
                updateSuccess: (updatedUser) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Avatar updated successfully!'), backgroundColor: Colors.green),
                  );
                  setState(() { _selectedImageFile = null; });
                },
                updateFailure: (error) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Avatar update error: $error'), backgroundColor: theme.colorScheme.error),
                  );
                },
              );
            },
            child: BlocConsumer<AuthBloc, AuthState>(
              listener: (context, authState) {
                if (authState is Unauthenticated) {
                  context.go(AppRoutes.login);
                }
              },
              builder: (context, authState) {
                if (authState is Authenticated) {
                  final user = authState.user;
                  final String? profileImageUrl = user.profileImageUrl;
                  final profileBlocState = context.watch<ProfileBloc>().state;

                  Widget avatarDisplayWidget;
                  if (_selectedImageFile != null) {
                    avatarDisplayWidget = Image.file(_selectedImageFile!, fit: BoxFit.cover);
                  } else if (profileImageUrl != null && profileImageUrl.isNotEmpty && profileImageUrl.startsWith('http')) {
                    avatarDisplayWidget = CachedNetworkImage(
                      imageUrl: profileImageUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => CircularProgressIndicator(color: theme.colorScheme.primary),
                      errorWidget: (context, url, error) => Icon(Icons.error, color: theme.colorScheme.error),
                    );
                  } else {
                    avatarDisplayWidget = Center(
                      child: Text(
                        user.username.isNotEmpty ? user.username[0].toUpperCase() : '?',
                        style: TextStyle(fontSize: 50, color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
                      ),
                    );
                  }

                  return Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        const SizedBox(height: 40),
                        Center(
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              AnimatedScale(
                                scale: 1.0,
                                duration: const Duration(milliseconds: 600),
                                curve: Curves.easeOutBack,
                                child: CircleAvatar(
                                  radius: 70,
                                  backgroundColor: Colors.white.withOpacity(0.15),
                                  child: ClipOval(
                                    child: SizedBox(
                                      width: 140,
                                      height: 140,
                                      child: avatarDisplayWidget,
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 40,
                                child: Material(
                                  color: theme.colorScheme.secondary,
                                  shape: const CircleBorder(),
                                  elevation: 2,
                                  child: InkWell(
                                    onTap: () => _showImageSourceActionSheet(context),
                                    customBorder: const CircleBorder(),
                                    child: Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: Icon(
                                        Icons.edit,
                                        color: theme.colorScheme.onSecondary,
                                        size: 24,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              profileBlocState.maybeWhen(
                                loading: () => Container(
                                  width: 140,
                                  height: 140,
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.3),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.onPrimary),
                                    ),
                                  ),
                                ),
                                orElse: () => const SizedBox.shrink(),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 30),
                        AnimatedOpacity(
                          opacity: 1.0,
                          duration: const Duration(milliseconds: 800),
                          child: _buildProfileInfoCard(
                            context,
                            title: 'Username',
                            value: user.username,
                            icon: Icons.person_outline
                          ),
                        ),
                        const SizedBox(height: 12),
                        AnimatedOpacity(
                          opacity: 1.0,
                          duration: const Duration(milliseconds: 900),
                          child: _buildProfileInfoCard(
                            context,
                            title: 'Email',
                            value: user.email,
                            icon: Icons.email_outlined
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (user.bio != null && user.bio!.isNotEmpty) ...[
                          AnimatedOpacity(
                            opacity: 1.0,
                            duration: const Duration(milliseconds: 1000),
                            child: _buildProfileInfoCard(
                              context,
                              title: 'About',
                              value: user.bio!,
                              icon: Icons.info_outline
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                        AnimatedOpacity(
                          opacity: 1.0,
                          duration: const Duration(milliseconds: 1100),
                          child: _buildProfileInfoCard(
                            context,
                            title: 'User ID',
                            value: user.id,
                            icon: Icons.fingerprint
                          ),
                        ),
                        const Spacer(),
                        AnimatedScale(
                          scale: 1.0,
                          duration: const Duration(milliseconds: 700),
                          curve: Curves.easeOutBack,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.logout),
                            label: const Text('Log out'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white.withOpacity(0.15),
                              foregroundColor: theme.colorScheme.error,
                              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            onPressed: () {
                              _showLogoutConfirmationDialog(context);
                            },
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  );
                } else if (authState is AuthLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Failed to load user data. Please try to log in again.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: theme.colorScheme.error),
                      ),
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileInfoCard(BuildContext context, {required String title, required String value, IconData? icon}) {
    final ThemeData theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: theme.colorScheme.primary, size: 28),
              const SizedBox(width: 16),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.textTheme.titleSmall?.color?.withOpacity(0.7)
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutConfirmationDialog(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: theme.colorScheme.error),
              const SizedBox(width: 10),
              const Text('Log out'),
            ],
          ),
          content: const Text('Are you sure you want to log out?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.error,
                foregroundColor: theme.colorScheme.onError,
              ),
              child: const Text('Log out'),
              onPressed: () {
                BlocProvider.of<AuthBloc>(context).add(LogoutRequested());
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
