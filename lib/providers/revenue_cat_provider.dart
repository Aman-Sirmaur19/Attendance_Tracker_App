import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../services/ad_manager.dart';

class RevenueCatProvider with ChangeNotifier {
  String? _activeProductId;
  bool _isPro = false;
  bool _isLoading = false;
  bool _isPurchasing = false;
  bool _lastPurchaseCancelled = false;
  Offerings? _offerings;

  bool get isPro => _isPro;

  String? get activeProductId => _activeProductId;

  bool get isLoading => _isLoading;

  bool get isPurchasing => _isPurchasing;

  bool get lastPurchaseCancelled => _lastPurchaseCancelled;

  Offerings? get offerings => _offerings;

  RevenueCatProvider() {
    _init();
  }

  Future<void> _init() async {
    _setLoading(true);
    Purchases.addCustomerInfoUpdateListener(_updateCustomerInfo);
    await _checkCurrentUserPurchases();
    await _loadOfferings();
    _setLoading(false);
  }

  Future<void> _checkCurrentUserPurchases() async {
    try {
      CustomerInfo customerInfo = await Purchases.getCustomerInfo();
      _updateCustomerInfo(customerInfo);
    } on PlatformException catch (e) {
      debugPrint("Error fetching customer info: ${e.message}");
    }
  }

  Future<void> _loadOfferings() async {
    try {
      _offerings = await Purchases.getOfferings();
    } on PlatformException catch (e) {
      debugPrint("Error loading offerings: ${e.message}");
      _offerings = null;
    }
    notifyListeners();
  }

  void _updateCustomerInfo(CustomerInfo customerInfo) {
    debugPrint("Customer info updated.");
    if (customerInfo.activeSubscriptions.isNotEmpty) {
      _activeProductId = customerInfo.activeSubscriptions.first;
    } else {
      _activeProductId = null;
    }
    if (customerInfo.entitlements.active['pro'] != null) {
      _isPro = true;
    } else {
      _isPro = false;
    }
    AdManager().updateAdStatus(_isPro);
    notifyListeners();
  }

  Future<bool> purchasePackage(Package package) async {
    _setPurchasing(true);
    _lastPurchaseCancelled = false;
    try {
      await Purchases.purchase(PurchaseParams.package(package));
      _setPurchasing(false);
      return true;
    } on PlatformException catch (e) {
      var errorCode = PurchasesErrorHelper.getErrorCode(e);
      if (errorCode == PurchasesErrorCode.purchaseCancelledError) {
        _lastPurchaseCancelled = true;
        debugPrint("Purchase cancelled by user.");
      } else {
        debugPrint("Purchase failed: ${e.message}");
      }
    }
    _setPurchasing(false);
    return false;
  }

  Future<bool> restorePurchases() async {
    _setLoading(true);
    try {
      await Purchases.restorePurchases();
    } on PlatformException catch (e) {
      debugPrint("Restore failed: ${e.message}");
      _setLoading(false);
      return false;
    }
    _setLoading(false);
    return true;
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setPurchasing(bool purchasing) {
    _isPurchasing = purchasing;
    notifyListeners();
  }
}
