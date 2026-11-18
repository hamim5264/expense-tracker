import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:expense_tracker/core/services/ad_service.dart';

/// Reusable adaptive banner advertisement widget for the Onyx app.
///
/// Features:
/// - Uses Google Mobile Ads anchored adaptive banner sizing.
/// - Graceful loading with an elegant, non-intrusive Onyx-themed placeholder.
/// - Graceful collapse (`SizedBox.shrink()`) on load failure or when ads are disabled.
/// - Safe lifecycle management and memory leak prevention with proper [BannerAd.dispose].
/// - Respects safe area constraints without overflowing or covering navigation elements.
class OnyxBannerAd extends StatefulWidget {
  final EdgeInsetsGeometry padding;
  final bool showPlaceholder;

  const OnyxBannerAd({
    super.key,
    this.padding = const EdgeInsets.symmetric(vertical: 8),
    this.showPlaceholder = true,
  });

  @override
  State<OnyxBannerAd> createState() => _OnyxBannerAdState();
}

class _OnyxBannerAdState extends State<OnyxBannerAd> {
  BannerAd? _bannerAd;
  AdSize? _adSize;
  bool _isAdLoaded = false;
  bool _isAdFailed = false;
  bool _isLoading = false;
  int? _lastRequestedWidth;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadAdIfNeeded();
  }

  Future<void> _loadAdIfNeeded() async {
    if (!AdService.areAdsGloballyEnabled) return;
    if (_isLoading || _isAdLoaded) return;

    // Ensure SDK is initialized
    if (!AdService.isInitialized) {
      await AdService.initialize();
      if (!mounted) return;
    }

    final screenWidth = MediaQuery.sizeOf(context).width.truncate();
    if (screenWidth <= 0) return;

    // Avoid duplicate requests for the same width
    if (_lastRequestedWidth == screenWidth && (_bannerAd != null || _isAdFailed)) {
      return;
    }
    _lastRequestedWidth = screenWidth;

    _isLoading = true;

    try {
      // Get Anchored Adaptive Banner size for the current orientation and screen width
      final AdSize? size = await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(screenWidth);
      if (!mounted) {
        _isLoading = false;
        return;
      }

      if (size == null) {
        debugPrint('⚠️ [OnyxBannerAd] Unable to calculate adaptive banner size for width: $screenWidth');
        setState(() {
          _isAdFailed = true;
          _isLoading = false;
        });
        return;
      }

      // Dispose previous ad instance if any
      await _bannerAd?.dispose();
      _bannerAd = null;

      final banner = BannerAd(
        adUnitId: AdService.bannerAdUnitId,
        size: size,
        request: AdService.createPrivacyCompliantAdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (Ad ad) {
            if (!mounted) {
              ad.dispose();
              return;
            }
            debugPrint('✅ [OnyxBannerAd] Adaptive banner loaded successfully: ${ad.responseInfo?.responseId}');
            setState(() {
              _bannerAd = ad as BannerAd;
              _adSize = size;
              _isAdLoaded = true;
              _isAdFailed = false;
              _isLoading = false;
            });
          },
          onAdFailedToLoad: (Ad ad, LoadAdError error) {
            debugPrint('⚠️ [OnyxBannerAd] Failed to load banner ad: ${error.message} (code: ${error.code})');
            ad.dispose();
            if (!mounted) return;
            setState(() {
              _bannerAd = null;
              _isAdLoaded = false;
              _isAdFailed = true;
              _isLoading = false;
            });
          },
          onAdOpened: (Ad ad) => debugPrint('ℹ️ [OnyxBannerAd] Ad opened.'),
          onAdClosed: (Ad ad) => debugPrint('ℹ️ [OnyxBannerAd] Ad closed.'),
          onAdImpression: (Ad ad) => debugPrint('ℹ️ [OnyxBannerAd] Ad impression recorded.'),
        ),
      );

      await banner.load();
    } catch (e) {
      debugPrint('⚠️ [OnyxBannerAd] Exception during banner loading: $e');
      if (mounted) {
        setState(() {
          _isAdFailed = true;
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    _bannerAd = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!AdService.areAdsGloballyEnabled || _isAdFailed) {
      return const SizedBox.shrink();
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isAdLoaded && _bannerAd != null && _adSize != null) {
      return SafeArea(
        top: false,
        bottom: false,
        child: Padding(
          padding: widget.padding,
          child: Center(
            child: Container(
              width: _adSize!.width.toDouble(),
              height: _adSize!.height.toDouble(),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: isDark ? const Color(0xFF1E1A2C) : const Color(0xFFF8F6FC),
              ),
              clipBehavior: Clip.antiAlias,
              child: AdWidget(ad: _bannerAd!),
            ),
          ),
        ),
      );
    }

    if (_isLoading && widget.showPlaceholder) {
      final placeholderHeight = _adSize?.height.toDouble() ?? 50.0;
      return SafeArea(
        top: false,
        bottom: false,
        child: Padding(
          padding: widget.padding,
          child: Center(
            child: Container(
              height: placeholderHeight,
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withOpacity(0.04)
                    : Colors.black.withOpacity(0.03),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withOpacity(0.08)
                      : Colors.black.withOpacity(0.06),
                  width: 1,
                ),
              ),
              alignment: Alignment.center,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF2C243E) : const Color(0xFFEDE4FA),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Ad',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: isDark ? const Color(0xFFA69EB8) : const Color(0xFF6B4EE6),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Sponsored',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? Colors.white38 : Colors.black38,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}

