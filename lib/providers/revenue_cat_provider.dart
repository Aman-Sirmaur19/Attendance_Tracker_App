import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class RevenueCatProvider with ChangeNotifier {
  String? _activeProductId;
  bool _isPro = false;
  bool _isUltimate = false;
  bool _isLoading = false;
  bool _isPurchasing = false;
  bool _lastPurchaseCancelled = false;
  Offerings? _offerings;

  bool get isPro => _isPro;

  bool get isUltimate => _isUltimate;

  // Helper: true if user has ANY paid plan
  bool get isPremium => _isPro || _isUltimate;

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
      // Debug prints
      if (_offerings?.current != null) {
        debugPrint("✅ RevenueCat: Offerings Loaded!");
        for (var p in _offerings!.current!.availablePackages) {
          debugPrint(" -> Package: '${p.identifier}'");
        }
      }
    } on PlatformException catch (e) {
      debugPrint("Error loading offerings: ${e.message}");
      _offerings = null;
    }
    notifyListeners();
  }

  void _updateCustomerInfo(CustomerInfo customerInfo) {
    // 1. Update Active Product ID
    if (customerInfo.activeSubscriptions.isNotEmpty) {
      // We grab the first active subscription to use for upgrades later
      _activeProductId = customerInfo.activeSubscriptions.first;
    } else {
      _activeProductId = null;
    }

    // 2. Check Entitlements
    _isPro = customerInfo.entitlements.active['pro'] != null;
    _isUltimate = customerInfo.entitlements.active['ultimate'] != null;

    notifyListeners();
  }

  Future<bool> purchasePackage(Package package) async {
    _setPurchasing(true);
    _lastPurchaseCancelled = false;

    try {
      PurchaseParams params;

      // --- ANDROID UPGRADE/DOWNGRADE LOGIC ---
      if (Platform.isAndroid && _activeProductId != null) {
        // If we have an active subscription, we must tell Google this is a replacement.
        // IMMEDIATE_WITH_TIME_PRORATION is standard for upgrades (User gets credit for unused time).
        debugPrint("Android: Upgrading/Downgrading from $_activeProductId");

        // FIX: Pass googleProductChangeInfo as a named parameter in the constructor
        params = PurchaseParams.package(
          package,
          googleProductChangeInfo: GoogleProductChangeInfo(_activeProductId!,
              prorationMode: GoogleProrationMode.immediateWithTimeProration),
        );
      } else {
        // iOS or standard purchase (no active sub)
        params = PurchaseParams.package(package);
      }
      // ----------------------------------------

      await Purchases.purchase(params);
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
