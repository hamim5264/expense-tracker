import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Centralized service for Google Mobile Ads (AdMob) configuration and lifecycle in Onyx.
class AdService {
  AdService._();

  /// Global feature flag to enable or disable ads application-wide.
  /// Set this to false to immediately turn off all ads across the app.
  static const bool areAdsGloballyEnabled = true;

  /// Safety switch: Set to `true` ONLY when AdMob account, app approval,
  /// and policy compliance are fully confirmed for production release.
  /// When `false`, the app strictly requests official Google Test Ads.
  static const bool useProductionAds = true;

  /// Official Google AdMob Application ID (configured in AndroidManifest.xml)
  static const String androidAppId = 'ca-app-pub-5425140991928269~1214297635';

  /// Official Google Test Banner Ad Unit ID (Android)
  /// Always safe to test, will never cause policy violations or invalid traffic.
  static const String testBannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111';

  /// Official Production Banner Ad Unit ID (Android)
  static const String productionBannerAdUnitId = 'ca-app-pub-5425140991928269/1603299549';

  /// Returns the appropriate Banner Ad Unit ID based on environment and safety flag.
  /// In debug or profile mode, this ALWAYS returns the Google test ad unit ID.
  /// In release mode, it only returns the production ad unit ID if [useProductionAds] is explicitly true.
  static String get bannerAdUnitId {
    if (kReleaseMode && useProductionAds) {
      return productionBannerAdUnitId;
    }
    return testBannerAdUnitId;
  }

  static bool _isInitialized = false;
  static bool _isInitializing = false;

  /// Whether the Mobile Ads SDK has been successfully initialized.
  static bool get isInitialized => _isInitialized;

  /// Initializes the Google Mobile Ads SDK exactly once.
  /// This method is non-blocking, fail-safe, and prevents duplicate initialization.
  static Future<InitializationStatus?> initialize() async {
    if (!areAdsGloballyEnabled) {
      debugPrint('ℹ️ [AdService] Ads are globally disabled. Skipping initialization.');
      return null;
    }

    if (_isInitialized) {
      return null;
    }

    if (_isInitializing) {
      debugPrint('ℹ️ [AdService] MobileAds initialization already in progress.');
      return null;
    }

    _isInitializing = true;

    try {
      final status = await MobileAds.instance.initialize();
      _isInitialized = true;
      debugPrint('✅ [AdService] Google Mobile Ads SDK initialized successfully.');
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

  /// Creates a standard, privacy-compliant [AdRequest].
  ///
  /// CRITICAL PRIVACY ASSURANCE:
  /// Onyx NEVER passes transaction history, SMS content, account numbers,
  /// category totals, or any personal financial data to the advertising network.
  static AdRequest createPrivacyCompliantAdRequest() {
    return const AdRequest();
  }
}

