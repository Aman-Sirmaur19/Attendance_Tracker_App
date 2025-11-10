import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../secrets.dart';

class AdManager {
  static final AdManager _instance = AdManager._internal();

  factory AdManager() => _instance;

  AdManager._internal();

  InterstitialAd? _interstitialAd;
  bool _adsEnabled = true;
  bool _isAdLoaded = false;
  bool _isAdLoading = false;
  int _navigationCount = 0;

  void updateAdStatus(bool isPro) {
    _adsEnabled = !isPro;
    log('Ad status updated: Ads enabled = $_adsEnabled');
    if (!_adsEnabled && _interstitialAd != null) {
      _interstitialAd?.dispose();
      _interstitialAd = null;
      _isAdLoaded = false;
    } else if (_adsEnabled &&
        _interstitialAd == null &&
        !_isAdLoaded &&
        !_isAdLoading) {
      _loadInterstitialAd();
    }
  }

  void initialize() {
    if (_adsEnabled) {
      _loadInterstitialAd();
    }
  }

  void _loadInterstitialAd() {
    if (!_adsEnabled) {
      log('Ads disabled, not loading interstitial.');
      return;
    }
    if (_isAdLoading) {
      log('Ad is already loading.');
      return;
    }
    _isAdLoading = true;
    log('Loading interstitial ad...');
    InterstitialAd.load(
      adUnitId: Secrets.interstitialAdId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isAdLoaded = true;
          _isAdLoading = false;
          _interstitialAd?.fullScreenContentCallback =
              FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _isAdLoaded = false;
              _loadInterstitialAd();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              log('Ad failed to show: ${error.message}');
              ad.dispose();
              _isAdLoaded = false;
              _isAdLoading = false;
              _navigationCount = 2;
              _loadInterstitialAd();
            },
          );
        },
        onAdFailedToLoad: (error) {
          log('Failed to load interstitial ad: ${error.message}');
          _isAdLoaded = false;
          _isAdLoading = false;
          _navigationCount = 2;
        },
      ),
    );
  }

  void _incrementNavigationCount() {
    _navigationCount++;
    if (_navigationCount >= 6) {
      _showInterstitialAd();
    }
  }

  void _showInterstitialAd() {
    if (!_adsEnabled) {
      log('Ads disabled, not showing interstitial.');
      return;
    }
    if (_isAdLoaded && _interstitialAd != null) {
      _interstitialAd?.show();
      _isAdLoaded = false;
      _interstitialAd = null;
      _navigationCount = 0;
    } else {
      if (!_isAdLoading) {
        log('Ad not ready, loading one.');
        _loadInterstitialAd();
      } else {
        log('Ad is not ready, but one is already loading.');
      }
    }
  }

  void navigateWithAd(BuildContext context, Widget page) {
    if (_adsEnabled) {
      AdManager()._incrementNavigationCount();
    }
    Navigator.push(context, CupertinoPageRoute(builder: (_) => page));
  }
}
