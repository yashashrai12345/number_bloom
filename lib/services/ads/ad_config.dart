import 'package:flutter/foundation.dart';

/// Configuration for Google Mobile Ads IDs.
///
/// Automatically provides official Google test ad unit IDs in debug/test modes
/// and isolates production ad IDs for release builds.
class AdConfig {
  // Official Google test ad unit IDs
  static const String testBannerId = 'ca-app-pub-3940256099942544/6300978111';
  static const String testInterstitialId = 'ca-app-pub-3940256099942544/1033173712';

  // Production ad IDs (to be filled by publisher in release)
  static const String prodBannerId = 'ca-app-pub-3940256099942544/6300978111';
  static const String prodInterstitialId = 'ca-app-pub-3940256099942544/1033173712';

  static String get bannerAdUnitId {
    if (kDebugMode || kProfileMode) {
      return testBannerId;
    }
    return prodBannerId;
  }

  static String get interstitialAdUnitId {
    if (kDebugMode || kProfileMode) {
      return testInterstitialId;
    }
    return prodInterstitialId;
  }
}
