import 'package:flutter/foundation.dart';

import '../services/ad_service.dart';
import 'revenue_cat_provider.dart';

class NavigationProvider with ChangeNotifier {
  AdService? _adService;
  RevenueCatProvider _revenueCatProvider;
  int _navigationCount = 0;

  NavigationProvider(this._revenueCatProvider);

  void updateRevenueCat(RevenueCatProvider newProvider) {
    _revenueCatProvider = newProvider;
    if (_revenueCatProvider.isPremium) {
      _adService?.dispose();
      _adService = null;
      _navigationCount = 0;
    }
  }

  AdService? _getAdService() {
    if (_revenueCatProvider.isPremium) {
      _adService?.dispose();
      _adService = null;
      return null;
    }
    _adService ??= AdService();
    return _adService;
  }

  void increment() {
    if (_revenueCatProvider.isPremium) {
      _navigationCount = 0;
      return;
    }
    final adService = _getAdService();
    if (adService == null) return;
    _navigationCount++;
    if (_navigationCount >= 4) {
      adService.showInterstitialAd();
      _navigationCount = 0;
    } else if (_navigationCount == 2) {
      adService.loadInterstitialAd();
    }
  }

  @override
  void dispose() {
    _adService?.dispose();
    super.dispose();
  }
}
