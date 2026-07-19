import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:expense_tracker/core/common/utils/sound_service.dart';

class AnimationHelper {
  static void showSuccess(BuildContext context, String message) {
    SoundService.playSuccess();
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withAlpha(150),
      builder: (dialogContext) {
        Future.delayed(const Duration(seconds: 2), () {
          if (dialogContext.mounted && Navigator.canPop(dialogContext)) {
            Navigator.pop(dialogContext);
          }
        });
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.asset(
                'assets/animations/payment-success.json',
                width: 180,
                height: 180,
                repeat: false,
              ),
              const SizedBox(height: 16),
              Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }

  static void showFailed(BuildContext context, String message) {
    SoundService.playFailed();
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withAlpha(150),
      builder: (dialogContext) {
        Future.delayed(const Duration(seconds: 2), () {
          if (dialogContext.mounted && Navigator.canPop(dialogContext)) {
            Navigator.pop(dialogContext);
          }
        });
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.asset(
                'assets/animations/payment-failed.json',
                width: 180,
                height: 180,
                repeat: false,
              ),
              const SizedBox(height: 16),
              Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }
}
