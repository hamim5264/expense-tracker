import 'package:expense_tracker/core/common/utils/show_snackbar.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/auth_event.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/auth_state.dart';
import 'package:expense_tracker/features/auth/presentation/widgets/avatar_picker_sheet.dart';
import 'package:expense_tracker/features/auth/presentation/widgets/profile_text_field.dart';
import 'package:expense_tracker/features/expense/presentation/widgets/header_painter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileUpdatePage extends StatefulWidget {
  static Route route() =>
      MaterialPageRoute(builder: (context) => const ProfileUpdatePage());

  const ProfileUpdatePage({super.key});

  @override
  State<ProfileUpdatePage> createState() => _ProfileUpdatePageState();
}

class _ProfileUpdatePageState extends State<ProfileUpdatePage> {
  final nameController = TextEditingController();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  String? selectedAvatar;
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    final state = context.read<AuthBloc>().state;
    if (state is AuthSuccess) {
      nameController.text = state.user.name;
      usernameController.text = state.user.username ?? '';
      selectedAvatar = state.user.avatarUrl;
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _showAvatarPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withAlpha(80),
      builder: (context) {
        return AvatarPickerSheet(
          selectedAvatar: selectedAvatar,
          onAvatarSelected: (avatar) {
            setState(() {
              selectedAvatar = avatar;
            });
            Navigator.pop(context);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = isDark ? theme.scaffoldBackgroundColor : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: cardColor,
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            showToast('Profile updated successfully!');
            Navigator.pop(context);
          } else if (state is AuthFailure) {
            showToast(state.message, isError: true);
          }
        },
        builder: (context, state) {
          if (state is AuthSuccess) {
            final user = state.user;
            return Stack(
              children: [
                CustomPaint(
                  size: Size(MediaQuery.of(context).size.width, 280),
                  painter: HeaderPainter(),
                ),
                Positioned(
                  top: -20,
                  left: -20,
                  child: Opacity(
                    opacity: 0.80,
                    child: Image.asset(
                      'assets/images/components/background_design.png',
                      width: 250,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                SafeArea(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(
                                Icons.arrow_back_ios_new,
                                color: Colors.white,
                              ),
                            ),
                            const Text(
                              'Profile',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              onPressed: () {},
                              icon: const Icon(
                                Icons.notifications_none,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 100),
                      GestureDetector(
                        onTap: _showAvatarPicker,
                        child: Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 4,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withAlpha(20),
                                    blurRadius: 10,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: CircleAvatar(
                                radius: 50,
                                backgroundColor:
                                    (selectedAvatar == null &&
                                        user.avatarUrl == null)
                                    ? const Color(0xFF4F378A).withAlpha(60)
                                    : Colors.white,
                                backgroundImage: selectedAvatar != null
                                    ? NetworkImage(selectedAvatar!)
                                    : (user.avatarUrl != null
                                          ? NetworkImage(user.avatarUrl!)
                                          : null),
                                child:
                                    (selectedAvatar == null &&
                                        user.avatarUrl == null)
                                    ? const Icon(
                                        Icons.person,
                                        size: 50,
                                        color: Color(0xFFD1BCFF),
                                      )
                                    : null,
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Color(0xFF4F378A),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: Text(
                          user.name,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                      ),
                      Center(
                        child: Text(
                          user.username != null &&
                                  user.username!.trim().isNotEmpty
                              ? '@${user.username}'
                              : 'Set username',
                          style: TextStyle(
                            color:
                                user.username != null &&
                                    user.username!.trim().isNotEmpty
                                ? const Color(0xFF9E82F0)
                                : Colors.redAccent,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Expanded(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            children: [
                              ProfileTextField(
                                label: 'Name',
                                controller: nameController,
                              ),
                              const SizedBox(height: 20),
                              ProfileTextField(
                                label: 'Username',
                                controller: usernameController,
                              ),
                              const SizedBox(height: 20),
                              ProfileTextField(
                                label: 'Email',
                                controller: TextEditingController(
                                  text: user.email,
                                ),
                                enabled: false,
                              ),
                              const SizedBox(height: 20),
                              ProfileTextField(
                                label: 'Password',
                                controller: passwordController,
                                isPassword: !_isPasswordVisible,
                                onToggleVisibility: () {
                                  setState(() {
                                    _isPasswordVisible = !_isPasswordVisible;
                                  });
                                },
                              ),
                              const SizedBox(height: 40),
                              ElevatedButton(
                                onPressed: () {
                                  final name = nameController.text.trim();
                                  final username = usernameController.text
                                      .trim();
                                  final password = passwordController.text
                                      .trim();

                                  if (name.isEmpty) {
                                    showToast(
                                      'Name cannot be empty',
                                      isError: true,
                                    );
                                    return;
                                  }

                                  context.read<AuthBloc>().add(
                                    AuthUpdateUserProfile(
                                      name: name,
                                      username: username.isEmpty
                                          ? null
                                          : username,
                                      avatarUrl: selectedAvatar,
                                    ),
                                  );

                                  if (password.isNotEmpty) {
                                    context.read<AuthBloc>().add(
                                      AuthUpdatePassword(password),
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF4F378A),
                                  minimumSize: const Size(double.infinity, 50),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                ),
                                child: const Text(
                                  'Update profile',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                              const SizedBox(height: 30),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (state is AuthLoading)
                  const Center(child: CircularProgressIndicator()),
              ],
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
