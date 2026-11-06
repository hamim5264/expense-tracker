import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NotificationsHeaderWidget extends StatelessWidget {
  final int unreadCount;
  final int totalCount;
  final VoidCallback onBack;
  final VoidCallback onMarkAllRead;
  final VoidCallback onDeleteAll;

  const NotificationsHeaderWidget({
    super.key,
    required this.unreadCount,
    required this.totalCount,
    required this.onBack,
    required this.onMarkAllRead,
    required this.onDeleteAll,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF633BA7),
            Color(0xFF492B83),
            Color(0xFF36216C),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(38),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 28),
          child: Column(
            children: [
              // Navigation Bar Row
              Row(
                children: [
                  _buildCircularButton(
                    icon: CupertinoIcons.back,
                    onTap: onBack,
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Notifications',
                          maxLines: 1,
                          style: TextStyle(
                            fontSize: 23,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.3,
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          'Stay updated with Onyx',
                          maxLines: 1,
                          style: TextStyle(
                            color: Color(0xFFD9C9F3),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildCircularButton(
                    icon: CupertinoIcons.checkmark_alt_circle,
                    tooltip: 'Mark all as read',
                    onTap: onMarkAllRead,
                  ),
                  const SizedBox(width: 8),
                  _buildCircularButton(
                    icon: CupertinoIcons.trash,
                    tooltip: 'Delete all',
                    onTap: onDeleteAll,
                  ),
                ],
              ),

              const SizedBox(height: 22),

              // Banner Card with 3D Bell Art
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.18),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.12),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.14),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: const Icon(
                              CupertinoIcons.bell,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '$unreadCount New',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  'Total $totalCount notification${totalCount == 1 ? '' : 's'}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Color(0xFFD9C9F3),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  // Stylized 3D Bell with clapper & golden sparkles
                  const _Bell3DGraphic(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCircularButton({
    required IconData icon,
    required VoidCallback onTap,
    String? tooltip,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.14),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withOpacity(0.18),
              width: 1,
            ),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 20,
          ),
        ),
      ),
    );
  }
}

class _Bell3DGraphic extends StatelessWidget {
  const _Bell3DGraphic();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 78,
      height: 78,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // Golden sparkle arcs on top right
          Positioned(
            right: 0,
            top: 4,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Transform.rotate(
                  angle: 0.3,
                  child: Container(
                    width: 4.5,
                    height: 12,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFD54F),
                      borderRadius: BorderRadius.circular(3),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFFD54F).withOpacity(0.6),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 3),
                Transform.rotate(
                  angle: 0.6,
                  child: Container(
                    width: 4.5,
                    height: 10,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFE082),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Main 3D Bell Body (Tilted lilac bell)
          Transform.rotate(
            angle: -0.15,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                // Soft glow shadow beneath bell
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFC0A0FF).withOpacity(0.4),
                        blurRadius: 18,
                        spreadRadius: 2,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                ),

                // Main Bell Shell (3D Radial Gradient)
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    gradient: const RadialGradient(
                      center: Alignment(-0.3, -0.4),
                      radius: 0.9,
                      colors: [
                        Color(0xFFE8DDFF),
                        Color(0xFFC8B0F8),
                        Color(0xFF9E7FE0),
                      ],
                    ),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(28),
                      bottom: Radius.circular(16),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.25),
                        blurRadius: 10,
                        offset: const Offset(2, 6),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Container(
                      width: 14,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ),

                // Golden Clapper Bead
                Positioned(
                  bottom: -5,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      gradient: const RadialGradient(
                        center: Alignment(-0.3, -0.3),
                        colors: [
                          Color(0xFFFFEE58),
                          Color(0xFFFFA000),
                        ],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFFA000).withOpacity(0.6),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
