import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AvatarPickerSheet extends StatefulWidget {
  final String? selectedAvatar;
  final Function(String) onAvatarSelected;

  const AvatarPickerSheet({
    super.key,
    required this.selectedAvatar,
    required this.onAvatarSelected,
  });

  @override
  State<AvatarPickerSheet> createState() => _AvatarPickerSheetState();
}

class _AvatarPickerSheetState extends State<AvatarPickerSheet> {
  bool isMaleSelected = true;

  final List<String> maleAvatars = List.generate(
    12,
    (i) => 'https://api.dicebear.com/7.x/avataaars/png?seed=Onyx_Male_v2_$i',
  );

  final List<String> femaleAvatars = List.generate(
    12,
    (i) => 'https://api.dicebear.com/7.x/avataaars/png?seed=Onyx_Female_v2_$i',
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final list = isMaleSelected ? maleAvatars : femaleAvatars;
    final primaryColor = theme.primaryColor;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.black.withAlpha(140)
                : Colors.white.withAlpha(220),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            border: Border.all(
              color: isDark
                  ? Colors.white.withAlpha(30)
                  : Colors.black.withAlpha(15),
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white30 : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Choose your avatar',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () => setState(() => isMaleSelected = true),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isMaleSelected
                            ? primaryColor
                            : (isDark ? Colors.white10 : Colors.grey.shade100),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: isMaleSelected
                              ? primaryColor
                              : (isDark ? Colors.white24 : Colors.black12),
                          width: 1.2,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            CupertinoIcons.person_fill,
                            size: 16,
                            color: isMaleSelected ? Colors.white : textColor,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Male',
                            style: TextStyle(
                              color: isMaleSelected ? Colors.white : textColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  GestureDetector(
                    onTap: () => setState(() => isMaleSelected = false),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: !isMaleSelected
                            ? primaryColor
                            : (isDark ? Colors.white10 : Colors.grey.shade100),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: !isMaleSelected
                              ? primaryColor
                              : (isDark ? Colors.white24 : Colors.black12),
                          width: 1.2,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            CupertinoIcons.person_fill,
                            size: 16,
                            color: !isMaleSelected ? Colors.white : textColor,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Female',
                            style: TextStyle(
                              color: !isMaleSelected ? Colors.white : textColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 220,
                child: GridView.builder(
                  physics: const BouncingScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                  ),
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final avatar = list[index];
                    final isSelected = widget.selectedAvatar == avatar;
                    return GestureDetector(
                      onTap: () => widget.onAvatarSelected(avatar),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? primaryColor : Colors.transparent,
                            width: 3,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: primaryColor.withOpacity(0.4),
                                    blurRadius: 10,
                                    spreadRadius: 2,
                                  ),
                                ]
                              : null,
                        ),
                        child: CircleAvatar(
                          backgroundColor: isDark
                              ? Colors.white12
                              : Colors.grey.shade200,
                          child: ClipOval(
                            child: Image.network(
                              avatar,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  CupertinoIcons.person_fill,
                                  color: primaryColor,
                                  size: 28,
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
