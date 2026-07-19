import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/auth_event.dart';

class DeleteFeedbackDialog extends StatefulWidget {
  const DeleteFeedbackDialog({super.key});

  @override
  State<DeleteFeedbackDialog> createState() => _DeleteFeedbackDialogState();
}

class _DeleteFeedbackDialogState extends State<DeleteFeedbackDialog> {
  String _selectedReason = 'Not using it anymore';
  final _commentsController = TextEditingController();
  bool _isSubmitting = false;

  final List<String> _reasons = [
    'It is too complicated',
    'I found a better app',
    'Privacy or data concerns',
    'Not using it anymore',
    'Other (please specify)',
  ];

  @override
  void dispose() {
    _commentsController.dispose();
    super.dispose();
  }

  Future<void> _submitAndExecuteDelete() async {
    setState(() => _isSubmitting = true);
    try {
      final comments = _commentsController.text.trim();

      await Supabase.instance.client.from('delete_feedbacks').insert({
        'reason': _selectedReason,
        'comments': comments.isEmpty ? null : comments,
      });
    } catch (e) {
      debugPrint('Error inserting delete feedback: $e');
    }

    if (mounted) {
      setState(() => _isSubmitting = false);
      Navigator.pop(context); // close feedback dialog
      context.read<AuthBloc>().add(AuthDeleteAccount());
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;

    return AlertDialog(
      backgroundColor: isDark ? const Color(0xFF1E1B24) : Colors.white,
      title: const Text(
        'We are sorry to see you go!',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
      content: _isSubmitting
          ? const SizedBox(
              height: 150,
              child: Center(
                child: CircularProgressIndicator(color: Color(0xFF4F378A)),
              ),
            )
          : SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Please share why you are deleting your account to help us improve:',
                    style: TextStyle(fontSize: 13, height: 1.4),
                  ),
                  const SizedBox(height: 12),
                  ..._reasons.map((reason) {
                    final isSelected = reason == _selectedReason;
                    return InkWell(
                      onTap: () {
                        setState(() {
                          _selectedReason = reason;
                        });
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF4F378A).withAlpha(20)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF4F378A)
                                : Colors.transparent,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFF4F378A)
                                      : Colors.grey,
                                  width: 2,
                                ),
                              ),
                              child: isSelected
                                  ? Center(
                                      child: Container(
                                        width: 10,
                                        height: 10,
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Color(0xFF4F378A),
                                        ),
                                      ),
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                reason,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                  color: textColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _commentsController,
                    maxLines: 3,
                    style: TextStyle(color: textColor, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Additional comments (optional)',
                      hintStyle: const TextStyle(
                        color: Colors.grey,
                        fontSize: 13,
                      ),
                      filled: true,
                      fillColor: isDark ? Colors.white10 : Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
      actions: _isSubmitting
          ? []
          : [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: _submitAndExecuteDelete,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text('Submit & Delete'),
              ),
            ],
    );
  }
}
