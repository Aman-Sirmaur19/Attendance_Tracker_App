import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../secrets.dart';
import '../providers/revenue_cat_provider.dart';

class CustomBannerAd extends StatefulWidget {
  const CustomBannerAd({super.key});

  @override
  State<CustomBannerAd> createState() => _CustomBannerAdState();
}

class _CustomBannerAdState extends State<CustomBannerAd> {
  BannerAd? bannerAd;
  NativeAd? nativeAd;
  bool isBannerAdLoaded = false;
  bool isNativeAdLoaded = false;
  bool adsInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final isPremium = context.watch<RevenueCatProvider>().isPremium;
    if (!adsInitialized && !isPremium) {
      adsInitialized = true;
      _initializeBannerAd();
    }
  }

  Future<void> _initializeBannerAd() async {
    bannerAd = BannerAd(
      size: AdSize.banner,
      adUnitId: Secrets.bannerAdId,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() => isBannerAdLoaded = true);
        },
        onAdFailedToLoad: (ad, error) {
          log('Failed to load banner ad: ${error.message}');
          ad.dispose();
          setState(() => isBannerAdLoaded = false);
          _initializeNativeAd();
        },
      ),
    );

    try {
      await bannerAd!.load();
    } catch (error) {
      log('Error loading banner ad: $error');
      setState(() => isBannerAdLoaded = false);
    }
  }

  Future<void> _initializeNativeAd() async {
    nativeAd = NativeAd(
      adUnitId: Secrets.nativeAdId,
      request: const AdRequest(),
      nativeTemplateStyle:
          NativeTemplateStyle(templateType: TemplateType.small),
      listener: NativeAdListener(
        onAdLoaded: (ad) => setState(() => isNativeAdLoaded = true),
        onAdFailedToLoad: (ad, error) {
          log('Failed to load native ad: ${error.message}');
          ad.dispose();
          setState(() => isNativeAdLoaded = false);
        },
      ),
    );

    try {
      await nativeAd!.load();
    } catch (error) {
      log('Error loading native ad: $error');
      setState(() => isNativeAdLoaded = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPremium = context.watch<RevenueCatProvider>().isPremium;

    if (isPremium) return const SizedBox();

    return isBannerAdLoaded
        ? SizedBox(height: 50, child: AdWidget(ad: bannerAd!))
        : isNativeAdLoaded
            ? SizedBox(height: 85, child: AdWidget(ad: nativeAd!))
            : const SizedBox();
  }

  @override
  void dispose() {
    bannerAd?.dispose();
    nativeAd?.dispose();
    super.dispose();
  }
}
