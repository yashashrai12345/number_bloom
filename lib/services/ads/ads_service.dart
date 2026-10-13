import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'ad_config.dart';

typedef ClockProvider = DateTime Function();

/// Centralized service handling AdMob initialization, banner loading,
/// and interstitial frequency pacing.
class AdsService {
  static const int interstitialCooldownSeconds = 180;

  final ClockProvider _clock;
  bool _isInitialized = false;
  DateTime? _lastInterstitialShownAt;
  int _gamesEndedSinceLastInterstitial = 0;
  InterstitialAd? _interstitialAd;
  bool _isLoadingInterstitial = false;

  AdsService({ClockProvider? clock}) : _clock = clock ?? DateTime.now;

  bool get isInitialized => _isInitialized;
  DateTime? get lastInterstitialShownAt => _lastInterstitialShownAt;
  int get gamesEndedSinceLastInterstitial => _gamesEndedSinceLastInterstitial;

  /// Initializes the Google Mobile Ads SDK without blocking app launch.
  Future<void> initialize() async {
    if (_isInitialized) return;
    if (kIsWeb ||
        (defaultTargetPlatform != TargetPlatform.android &&
            defaultTargetPlatform != TargetPlatform.iOS)) {
      return;
    }
    try {
      await MobileAds.instance.initialize();
      _isInitialized = true;
      loadInterstitial();
    } catch (e) {
      debugPrint('AdsService: Ads initialization skipped or failed: $e');
    }
  }

  /// Records that a game has completed (reached Game Over).
  void recordGameEnded() {
    _gamesEndedSinceLastInterstitial++;
  }

  /// Checks if an interstitial ad is eligible to show based on PRD Section 8.2 rules:
  /// - At most one interstitial per 180 seconds.
  /// - At least one game has ended since the last interstitial.
  bool isEligibleForInterstitial() {
    if (_gamesEndedSinceLastInterstitial < 1) return false;
    if (_lastInterstitialShownAt == null) return true;

    final now = _clock();
    final elapsed = now.difference(_lastInterstitialShownAt!).inSeconds;
    return elapsed >= interstitialCooldownSeconds;
  }

  /// Loads an interstitial ad in the background.
  void loadInterstitial() {
    if (_interstitialAd != null || _isLoadingInterstitial) return;
    _isLoadingInterstitial = true;

    InterstitialAd.load(
      adUnitId: AdConfig.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isLoadingInterstitial = false;
        },
        onAdFailedToLoad: (error) {
          debugPrint('AdsService: Interstitial failed to load: ${error.message}');
          _interstitialAd = null;
          _isLoadingInterstitial = false;
        },
      ),
    );
  }

  /// Shows the interstitial if eligible, then resets counters and reloads.
  /// Always invokes [onComplete] so the game flow is never blocked.
  void showInterstitialIfEligible({required VoidCallback onComplete}) {
    if (!isEligibleForInterstitial() || _interstitialAd == null) {
      onComplete();
      return;
    }

    final ad = _interstitialAd!;
    _interstitialAd = null;

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _lastInterstitialShownAt = _clock();
        _gamesEndedSinceLastInterstitial = 0;
        loadInterstitial();
        onComplete();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('AdsService: Interstitial failed to show: ${error.message}');
        ad.dispose();
        loadInterstitial();
        onComplete();
      },
    );

    try {
      ad.show();
    } catch (e) {
      debugPrint('AdsService: Exception showing interstitial: $e');
      onComplete();
    }
  }

  /// Disposes cached ads.
  void dispose() {
    _interstitialAd?.dispose();
    _interstitialAd = null;
  }
}
