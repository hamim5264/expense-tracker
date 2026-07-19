import 'package:flutter/material.dart';
import 'package:expense_tracker/features/auth/presentation/widgets/delete_feedback_dialog.dart';

class DeleteAccountCard extends StatefulWidget {
  const DeleteAccountCard({super.key});

  @override
  State<DeleteAccountCard> createState() => _DeleteAccountCardState();
}

class _DeleteAccountCardState extends State<DeleteAccountCard> {
  final _confirmController = TextEditingController();
  bool _canDelete = false;

  @override
  void dispose() {
    _confirmController.dispose();
    super.dispose();
  }

  void _showDeleteConfirmationDialog() {
    setState(() {
      _confirmController.clear();
      _canDelete = false;
    });

    showDialog(
      context: context,
      builder: (dialogContext) {
        final theme = Theme.of(dialogContext);
        final isDark = theme.brightness == Brightness.dark;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: isDark ? const Color(0xFF1E1B24) : Colors.white,
              title: const Text(
                'Delete Account Permanently?',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'This action is irreversible. All your transactions, settings, and profile info will be permanently wiped.',
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Please type "DELETE" to confirm:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _confirmController,
                    decoration: InputDecoration(
                      hintText: 'DELETE',
                      hintStyle: const TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: isDark ? Colors.white10 : Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (val) {
                      setDialogState(() {
                        _canDelete = val.trim() == 'DELETE';
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: _canDelete
                      ? () {
                          Navigator.pop(dialogContext);
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) => const DeleteFeedbackDialog(),
                          );
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    disabledBackgroundColor: Colors.redAccent.withAlpha(50),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Delete Permanently'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final subColor = isDark ? Colors.white60 : Colors.black54;

    return Card(
      color: isDark ? const Color(0xFF1E1B24) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.redAccent.withAlpha(50), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Danger Zone',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.redAccent,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Permanently delete your account. This will completely wipe all profiles, credentials, settings, and expense statements.',
              style: TextStyle(fontSize: 14, color: subColor),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _showDeleteConfirmationDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Delete Account'),
            ),
          ],
        ),
      ),
    );
  }
}
