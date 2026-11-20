import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Centralized service for Google Mobile Ads (AdMob) configuration and lifecycle in Onyx.
class AdService {
  AdService._();

  /// Global feature flag to enable or disable ads application-wide.
  static const bool areAdsGloballyEnabled = true;

  /// Safety switch: Set to `true` for production release.
  /// When `false`, the app strictly requests official Google Test Ads.
  static const bool useProductionAds = true;

  /// Official Google AdMob Application ID (configured in AndroidManifest.xml)
  static const String androidAppId = 'ca-app-pub-5425140991928269~1214297635';

  // --- Official Google Test Ad Unit IDs (Android) ---
  static const String testBannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111';
  static const String testInterstitialAdUnitId = 'ca-app-pub-3940256099942544/1033173712';
  static const String testAppOpenAdUnitId = 'ca-app-pub-3940256099942544/9257399448';
  static const String testRewardedAdUnitId = 'ca-app-pub-3940256099942544/5224354917';

  // --- Official Production Ad Unit IDs (Android) ---
  static const String productionBannerAdUnitId = 'ca-app-pub-5425140991928269/1603299549';
  static const String productionInterstitialAdUnitId = 'ca-app-pub-5425140991928269/9161958461';
  static const String productionAppOpenAdUnitId = 'ca-app-pub-5425140991928269/2596550114';
  static const String productionRewardedAdUnitId = 'ca-app-pub-5425140991928269/8884298855';

  static String get bannerAdUnitId => (kReleaseMode && useProductionAds) ? productionBannerAdUnitId : testBannerAdUnitId;
  static String get interstitialAdUnitId => (kReleaseMode && useProductionAds) ? productionInterstitialAdUnitId : testInterstitialAdUnitId;
  static String get appOpenAdUnitId => (kReleaseMode && useProductionAds) ? productionAppOpenAdUnitId : testAppOpenAdUnitId;
  static String get rewardedAdUnitId => (kReleaseMode && useProductionAds) ? productionRewardedAdUnitId : testRewardedAdUnitId;

  static bool _isInitialized = false;
  static bool _isInitializing = false;
  static bool _isAnyFullScreenAdShowing = false;

  /// Whether the Mobile Ads SDK has been successfully initialized.
  static bool get isInitialized => _isInitialized;
  static bool get isAnyFullScreenAdShowing => _isAnyFullScreenAdShowing;

  // ==========================================
  // INITIALIZATION
  // ==========================================
  static Future<InitializationStatus?> initialize() async {
    if (!areAdsGloballyEnabled) {
      debugPrint('ℹ️ [AdService] Ads are globally disabled. Skipping initialization.');
      return null;
    }

    if (_isInitialized) return null;
    if (_isInitializing) return null;

    _isInitializing = true;

    try {
      final status = await MobileAds.instance.initialize();
      _isInitialized = true;
      debugPrint('✅ [AdService] Google Mobile Ads SDK initialized successfully.');

      // Register lifecycle observer for App Open ads
      WidgetsBinding.instance.addObserver(_AdLifecycleObserver());

      // Preload full-screen ad units for instant delivery
      loadInterstitialAd();
      loadAppOpenAd();
      loadRewardedAd();

      return status;
    } catch (e, stackTrace) {
      _isInitialized = false;
      debugPrint('⚠️ [AdService] Failed to initialize Google Mobile Ads SDK: $e');
      debugPrint('$stackTrace');
      return null;
    } finally {
      _isInitializing = false;
    }
  }

  // ==========================================
  // PRIVACY COMPLIANCE
  // ==========================================
  static AdRequest createPrivacyCompliantAdRequest() {
    return const AdRequest();
  }

  // ==========================================
  // INTERSTITIAL ADS (Navigation throttled: every 2-3 minutes)
  // ==========================================
  static InterstitialAd? _interstitialAd;
  static bool _isLoadingInterstitial = false;
  static DateTime? _lastInterstitialShownTime;
  static const Duration _minInterstitialInterval = Duration(minutes: 2, seconds: 15);

  static void loadInterstitialAd() {
    if (!areAdsGloballyEnabled || _isLoadingInterstitial || _interstitialAd != null) return;
    _isLoadingInterstitial = true;

    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: createPrivacyCompliantAdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isLoadingInterstitial = false;
          debugPrint('✅ [AdService] Interstitial ad loaded.');
        },
        onAdFailedToLoad: (error) {
          _interstitialAd = null;
          _isLoadingInterstitial = false;
          debugPrint('⚠️ [AdService] Interstitial ad failed to load: ${error.message}');
        },
      ),
    );
  }

  /// Triggers full-screen navigation interstitial if at least 2 minutes have elapsed.
  static void showNavigationInterstitialIfAllowed({VoidCallback? onCompleted}) {
    if (!areAdsGloballyEnabled || _isAnyFullScreenAdShowing) {
      onCompleted?.call();
      return;
    }

    final now = DateTime.now();
    // Throttle: Only show if 2+ minutes have passed since last full-screen ad
    if (_lastInterstitialShownTime != null &&
        now.difference(_lastInterstitialShownTime!) < _minInterstitialInterval) {
      onCompleted?.call();
      return;
    }

    if (_interstitialAd == null) {
      loadInterstitialAd();
      onCompleted?.call();
      return;
    }

    final ad = _interstitialAd!;
    _interstitialAd = null;

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        _isAnyFullScreenAdShowing = true;
        _lastInterstitialShownTime = DateTime.now();
      },
      onAdDismissedFullScreenContent: (ad) {
        _isAnyFullScreenAdShowing = false;
        ad.dispose();
        loadInterstitialAd(); // Preload next
        onCompleted?.call();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        _isAnyFullScreenAdShowing = false;
        ad.dispose();
        loadInterstitialAd();
        onCompleted?.call();
      },
    );

    ad.show();
  }

  // ==========================================
  // APP OPEN ADS (When opening/resuming the app)
  // ==========================================
  static AppOpenAd? _appOpenAd;
  static bool _isLoadingAppOpen = false;
  static DateTime? _appOpenLoadTime;
  static DateTime? _lastAppOpenShownTime;
  static const Duration _minAppOpenInterval = Duration(minutes: 4);

  static void loadAppOpenAd() {
    if (!areAdsGloballyEnabled || _isLoadingAppOpen || isAppOpenAdAvailable) return;
    _isLoadingAppOpen = true;

    AppOpenAd.load(
      adUnitId: appOpenAdUnitId,
      request: createPrivacyCompliantAdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          _appOpenAd = ad;
          _appOpenLoadTime = DateTime.now();
          _isLoadingAppOpen = false;
          debugPrint('✅ [AdService] App open ad loaded.');
        },
        onAdFailedToLoad: (error) {
          _appOpenAd = null;
          _isLoadingAppOpen = false;
          debugPrint('⚠️ [AdService] App open ad failed to load: ${error.message}');
        },
      ),
    );
  }

  static bool get isAppOpenAdAvailable {
    return _appOpenAd != null &&
        _appOpenLoadTime != null &&
        DateTime.now().difference(_appOpenLoadTime!) < const Duration(hours: 4);
  }

  static void showAppOpenAdIfAvailable({VoidCallback? onCompleted}) {
    if (!areAdsGloballyEnabled || _isAnyFullScreenAdShowing) {
      onCompleted?.call();
      return;
    }

    final now = DateTime.now();
    // Throttle App Open ads
    if (_lastAppOpenShownTime != null &&
        now.difference(_lastAppOpenShownTime!) < _minAppOpenInterval) {
      onCompleted?.call();
      return;
    }

    // Don't show if an interstitial was just viewed in the last 1 minute
    if (_lastInterstitialShownTime != null &&
        now.difference(_lastInterstitialShownTime!) < const Duration(minutes: 1)) {
      onCompleted?.call();
      return;
    }

    if (!isAppOpenAdAvailable) {
      loadAppOpenAd();
      onCompleted?.call();
      return;
    }

    final ad = _appOpenAd!;
    _appOpenAd = null;

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        _isAnyFullScreenAdShowing = true;
        _lastAppOpenShownTime = DateTime.now();
      },
      onAdDismissedFullScreenContent: (ad) {
        _isAnyFullScreenAdShowing = false;
        ad.dispose();
        loadAppOpenAd();
        onCompleted?.call();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        _isAnyFullScreenAdShowing = false;
        ad.dispose();
        loadAppOpenAd();
        onCompleted?.call();
      },
    );

    ad.show();
  }

  // ==========================================
  // REWARDED VIDEO ADS (Watch to unlock AI / bonus)
  // ==========================================
  static RewardedAd? _rewardedAd;
  static bool _isLoadingRewarded = false;

  static void loadRewardedAd() {
    if (!areAdsGloballyEnabled || _isLoadingRewarded || _rewardedAd != null) return;
    _isLoadingRewarded = true;

    RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: createPrivacyCompliantAdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isLoadingRewarded = false;
          debugPrint('✅ [AdService] Rewarded video ad loaded.');
        },
        onAdFailedToLoad: (error) {
          _rewardedAd = null;
          _isLoadingRewarded = false;
          debugPrint('⚠️ [AdService] Rewarded video ad failed to load: ${error.message}');
        },
      ),
    );
  }

  static bool get isRewardedAdReady => _rewardedAd != null;

  static void showRewardedAd({
    required Function(RewardItem reward) onUserEarnedReward,
    VoidCallback? onDismissed,
    VoidCallback? onAdNotReady,
  }) {
    if (!areAdsGloballyEnabled || _isAnyFullScreenAdShowing) {
      onAdNotReady?.call();
      return;
    }

    if (_rewardedAd == null) {
      loadRewardedAd();
      onAdNotReady?.call();
      return;
    }

    final ad = _rewardedAd!;
    _rewardedAd = null;

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        _isAnyFullScreenAdShowing = true;
      },
      onAdDismissedFullScreenContent: (ad) {
        _isAnyFullScreenAdShowing = false;
        ad.dispose();
        loadRewardedAd(); // Preload next
        onDismissed?.call();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        _isAnyFullScreenAdShowing = false;
        ad.dispose();
        loadRewardedAd();
        onDismissed?.call();
      },
    );

    ad.show(onUserEarnedReward: (AdWithoutView adWithoutView, RewardItem reward) {
      onUserEarnedReward(reward);
    });
  }

  /// Displays a rewarded ad. If not ready yet, it preloads with a smooth loading dialog.
  /// Calls [onUserEarnedReward] when the user completes watching the video ad.
  static Future<void> showRewardedAdWithDialog({
    required BuildContext context,
    required String loadingMessage,
    required VoidCallback onUserEarnedReward,
    VoidCallback? onFailedOrDismissed,
  }) async {
    if (!areAdsGloballyEnabled) {
      onUserEarnedReward();
      return;
    }

    if (_isAnyFullScreenAdShowing) {
      Fluttertoast.showToast(msg: 'An ad is already displaying.');
      onFailedOrDismissed?.call();
      return;
    }

    if (_rewardedAd != null) {
      showRewardedAd(
        onUserEarnedReward: (_) => onUserEarnedReward(),
        onDismissed: onFailedOrDismissed,
        onAdNotReady: onFailedOrDismissed,
      );
      return;
    }

    // Show loading overlay
    bool isDialogShowing = true;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2C),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Row(
          children: [
            const CircularProgressIndicator(color: Color(0xFF8B4BD1)),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                loadingMessage,
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    ).then((_) => isDialogShowing = false);

    // Trigger load and wait up to 4 seconds
    loadRewardedAd();
    int attempts = 0;
    while (_rewardedAd == null && _isLoadingRewarded && attempts < 40) {
      await Future.delayed(const Duration(milliseconds: 100));
      attempts++;
    }

    if (context.mounted && isDialogShowing && Navigator.of(context, rootNavigator: true).canPop()) {
      Navigator.of(context, rootNavigator: true).pop();
    }

    if (_rewardedAd != null) {
      showRewardedAd(
        onUserEarnedReward: (_) => onUserEarnedReward(),
        onDismissed: onFailedOrDismissed,
        onAdNotReady: () {
          Fluttertoast.showToast(msg: 'Ad could not be displayed. Please try again.');
          onFailedOrDismissed?.call();
        },
      );
    } else {
      Fluttertoast.showToast(
        msg: 'Video ad is still loading. Please check your internet connection and try again.',
        toastLength: Toast.LENGTH_LONG,
      );
      onFailedOrDismissed?.call();
    }
  }
}

class _AdLifecycleObserver extends WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      AdService.showAppOpenAdIfAvailable();
    }
  }
}
