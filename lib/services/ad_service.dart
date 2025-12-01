import 'dart:developer';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../secrets.dart';

class AdService {
  InterstitialAd? _interstitialAd;
  bool _isAdLoaded = false;
  bool _isLoading = false;

  AdService() {
    log('AdService instantiated.');
  }

  void loadInterstitialAd() {
    if (_isAdLoaded || _isLoading) {
      return;
    }

    _isLoading = true;
    log('Loading Interstitial Ad...');

    InterstitialAd.load(
      adUnitId: Secrets.interstitialAdId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          log('Ad loaded successfully.');
          _interstitialAd = ad;
          _isAdLoaded = true;
          _isLoading = false;

          _interstitialAd?.fullScreenContentCallback =
              FullScreenContentCallback(
                onAdDismissedFullScreenContent: (ad) {
                  log('Ad dismissed.');
                  ad.dispose();
                  _isAdLoaded = false;
                  _interstitialAd = null;
                },
                onAdFailedToShowFullScreenContent: (ad, error) {
                  log('Ad failed to show: ${error.message}');
                  ad.dispose();
                  _isAdLoaded = false;
                  _interstitialAd = null;
                },
              );
        },
        onAdFailedToLoad: (error) {
          log('Failed to load interstitial ad: ${error.message}');
          _isAdLoaded = false;
          _isLoading = false;
        },
      ),
    );
  }

  void showInterstitialAd() {
    if (_isAdLoaded && _interstitialAd != null) {
      log('Showing Interstitial Ad...');
      _interstitialAd?.show();
      _isAdLoaded = false;
      _interstitialAd = null;
    } else {
      log('Show ad called, but ad was not loaded.');
      if (!_isLoading) {
        loadInterstitialAd();
      }
    }
  }

  void dispose() {
    log('Disposing AdService.');
    _interstitialAd?.dispose();
    _interstitialAd = null;
    _isAdLoaded = false;
    _isLoading = false;
  }
}
