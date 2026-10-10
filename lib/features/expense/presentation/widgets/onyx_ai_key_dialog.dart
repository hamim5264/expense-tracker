import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:expense_tracker/core/services/onyx_llm_service.dart';

class OnyxAiKeyDialog extends StatefulWidget {
  final bool isDark;
  final Color primaryColor;

  const OnyxAiKeyDialog({
    super.key,
    required this.isDark,
    required this.primaryColor,
  });

  static Future<void> show(BuildContext context, {required bool isDark, required Color primaryColor}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => OnyxAiKeyDialog(isDark: isDark, primaryColor: primaryColor),
    );
  }

  @override
  State<OnyxAiKeyDialog> createState() => _OnyxAiKeyDialogState();
}

class _OnyxAiKeyDialogState extends State<OnyxAiKeyDialog> {
  final TextEditingController _keyController = TextEditingController();
  bool _isLoading = true;
  String _currentKey = '';

  @override
  void initState() {
    super.initState();
    _loadKey();
  }

  Future<void> _loadKey() async {
    final key = await OnyxLlmService.instance.getApiKey();
    setState(() {
      _currentKey = key;
      _keyController.text = key;
      _isLoading = false;
    });
  }

  Future<void> _saveKey() async {
    final key = _keyController.text.trim();
    await OnyxLlmService.instance.setApiKey(key);
    Fluttertoast.showToast(msg: key.isEmpty ? 'Key cleared (Using defaults)' : 'OpenRouter API Key saved!');
    if (mounted) Navigator.pop(context);
  }

  @override
  void dispose() {
    _keyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bg = widget.isDark ? const Color(0xFF1E1B29) : Colors.white;
    final textColor = widget.isDark ? Colors.white : Colors.black87;
    final subColor = widget.isDark ? Colors.white60 : Colors.black54;

    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(
            color: widget.isDark ? Colors.white10 : Colors.black12,
          ),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(CupertinoIcons.sparkles, color: widget.primaryColor, size: 22),
                const SizedBox(width: 8),
                Text(
                  'Onyx Nova AI Settings',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Onyx AI uses 100% Free OpenRouter models (Llama 3.3 70B, Gemini 2.0 Flash & DeepSeek) with automatic fallback to on-device NLP.',
              style: TextStyle(fontSize: 12.5, color: subColor, height: 1.4),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _keyController,
              obscureText: true,
              style: TextStyle(color: textColor, fontSize: 13),
              decoration: InputDecoration(
                labelText: 'OpenRouter API Key (Optional)',
                hintText: 'sk-or-v1-...',
                labelStyle: TextStyle(color: subColor, fontSize: 12),
                hintStyle: TextStyle(color: Colors.grey.withOpacity(0.6), fontSize: 12),
                prefixIcon: Icon(CupertinoIcons.lock_shield_fill, color: widget.primaryColor, size: 18),
                filled: true,
                fillColor: widget.isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade100,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () async {
                    final uri = Uri.parse('https://openrouter.ai/keys');
                    try {
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                    } catch (_) {}
                  },
                  child: Text(
                    'Get a free API key at openrouter.ai ↗',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: widget.primaryColor,
                    ),
                  ),
                ),
                Text(
                  _currentKey.isNotEmpty ? 'Status: Active' : 'Status: Free Default',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF10B981),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                onPressed: _isLoading ? null : _saveKey,
                child: const Text(
                  'Save & Apply',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  ),
),
);
  }
}
