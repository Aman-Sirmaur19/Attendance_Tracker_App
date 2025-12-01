import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
// import 'package:collection/collection.dart'; // Ensure you have this for firstWhereOrNull if not included in your project already, otherwise use standard iterable methods or add the package.

import '../../utils/dialogs.dart';
import '../../providers/revenue_cat_provider.dart';

// --- Features Lists ---
const List<String> _proFeatures = [
  "Remove Ads",
  "Full Settings Access",
  "One Project Tracker",
];

const List<String> _ultimateFeatures = [
  "Everything in Pro",
  "Unlimited Projects Tracker",
  "Unlock Mini-Games",
  "All Upcoming Features",
];
// ----------------------

class SubscriptionsScreen extends StatefulWidget {
  final int initialIndex;

  const SubscriptionsScreen({super.key, this.initialIndex = 0});

  @override
  State<SubscriptionsScreen> createState() => _SubscriptionsScreenState();
}

class _SubscriptionsScreenState extends State<SubscriptionsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // Initialize TabController with 2 tabs
    _tabController = TabController(
      length: 2,
      initialIndex: widget.initialIndex,
      vsync: this,
    );

    // Add listener to rebuild UI (and change colors) when tab changes
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Determine the color based on the current tab index
    // Index 0 = Pro (Pink), Index 1 = Ultimate (DeepPurpleAccent)
    final Color activeColor =
        _tabController.index == 0 ? Colors.pink : Colors.deepPurpleAccent;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () => Navigator.pop(context),
            tooltip: 'Back',
            icon: const Icon(CupertinoIcons.chevron_back)),
        title: const Text("Subscriptions"),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          dividerHeight: 0,
          indicatorWeight: 3,
          // Use the dynamic activeColor
          indicatorColor: activeColor,
          labelColor: activeColor,
          unselectedLabelColor: Colors.grey,
          labelStyle: const TextStyle(
            fontSize: 16,
            fontFamily: 'Fredoka',
            fontWeight: FontWeight.bold,
          ),
          onTap: (index) {
            setState(() {}); // Ensure color updates immediately on tap
          },
          tabs: const [
            Tab(text: "PRO"),
            Tab(text: "ULTIMATE"),
          ],
        ),
      ),
      body: Consumer<RevenueCatProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return Center(child: CircularProgressIndicator(color: activeColor));
          }

          if (provider.offerings == null) {
            return const Center(
              child: Text("Could not load plans. Please try again later."),
            );
          }

          final offering = provider.offerings!.current;
          if (offering == null || offering.availablePackages.isEmpty) {
            return const Center(
              child: Text("No plans are currently available."),
            );
          }

          final packages = offering.availablePackages;

          // --- PRO Packages ---
          final Package? proMonthly =
              packages.where((p) => p.identifier == 'pro_monthly').firstOrNull;
          final Package? proYearly =
              packages.where((p) => p.identifier == 'pro_yearly').firstOrNull;

          // --- ULTIMATE Packages ---
          final Package? ultimateMonthly = packages
              .where((p) => p.identifier == 'ultimate_monthly')
              .firstOrNull;
          final Package? ultimateYearly = packages
              .where((p) => p.identifier == 'ultimate_yearly')
              .firstOrNull;

          return Stack(
            children: [
              TabBarView(
                controller: _tabController,
                children: [
                  // --- PRO TAB (Pink) ---
                  _buildPlanPage(
                    context: context,
                    provider: provider,
                    title: "PRO",
                    slogan: "Upgrade your workflow without ads.",
                    features: _proFeatures,
                    monthlyPackage: proMonthly,
                    yearlyPackage: proYearly,
                    isActiveTier: provider.isPro,
                    themeColor: Colors.pink,
                  ),

                  // --- ULTIMATE TAB (DeepPurpleAccent) ---
                  _buildPlanPage(
                    context: context,
                    provider: provider,
                    title: "ULTIMATE",
                    slogan: "Maximize your potential with no limits.",
                    features: _ultimateFeatures,
                    monthlyPackage: ultimateMonthly,
                    yearlyPackage: ultimateYearly,
                    isActiveTier: provider.isUltimate,
                    themeColor: Colors.deepPurpleAccent,
                  ),
                ],
              ),
              if (provider.isPurchasing)
                Container(
                  color: Colors.black.withOpacity(0.7),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(color: Colors.white),
                        const SizedBox(height: 20),
                        Text(
                          "Processing purchase...",
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPlanPage({
    required BuildContext context,
    required RevenueCatProvider provider,
    required String title,
    required String slogan,
    required List<String> features,
    required Package? monthlyPackage,
    required Package? yearlyPackage,
    required bool isActiveTier,
    required Color themeColor,
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: themeColor,
            ),
          ),
          Text(
            slogan,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
          ),
          const SizedBox(height: 24),
          Text(
            "What's Included ?",
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          ...features.map(
              (feature) => _buildFeatureListItem(context, feature, themeColor)),
          const SizedBox(height: 30),

          if (monthlyPackage != null)
            _buildSubscriptionCard(
              context,
              provider: provider,
              package: monthlyPackage,
              color: themeColor,
              isBestValue: false,
            ),
          const SizedBox(height: 16),

          if (yearlyPackage != null)
            _buildSubscriptionCard(
              context,
              provider: provider,
              package: yearlyPackage,
              color: themeColor,
              isBestValue: true,
            ),

          const SizedBox(height: 16),

          if (isActiveTier)
            Center(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle, color: Colors.green),
                    SizedBox(width: 8),
                    Text(
                      "You are currently on this plan.",
                      style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),

          // --- Show restore button if user is not premium at all ---
          if (!provider.isPremium) ...[
            const SizedBox(height: 20),
            Center(child: _restorePurchaseButton(context, provider)),
            const SizedBox(height: 20),
          ],
        ],
      ),
    );
  }

  Widget _buildFeatureListItem(
      BuildContext context, String feature, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(
            CupertinoIcons.check_mark_circled_solid,
            color: color,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              feature,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBestValueBadge(Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(16),
          bottomLeft: Radius.circular(16),
        ),
      ),
      child: const Text(
        "BEST VALUE",
        style: TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSubscriptionCard(
    BuildContext context, {
    required RevenueCatProvider provider,
    required Package package,
    required Color color,
    required bool isBestValue,
  }) {
    final product = package.storeProduct;
    final bool isThisPackageActive =
        provider.activeProductId == product.identifier;

    Widget cardContent = ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          width: 2,
          color: isThisPackageActive ? color : color.withOpacity(0.4),
        ),
      ),
      tileColor:
          isThisPackageActive ? color.withOpacity(0.05) : Colors.transparent,
      title: Text(
        // Parsing title safely
        '${product.title.split(' (').first} (${product.subscriptionPeriod == 'P1M' ? 'Monthly' : 'Yearly'})',
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(
        product.priceString,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
      trailing: isThisPackageActive
          ? Chip(
              label: const Text("Active"),
              side: BorderSide(color: color, width: 2),
              backgroundColor: color.withOpacity(0.1),
              labelStyle: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            )
          : Chip(
              label: const Text("Select"),
              backgroundColor: Colors.transparent,
              shape: StadiumBorder(side: BorderSide(color: color)),
              labelStyle: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
      onTap: isThisPackageActive
          ? null
          : () async {
              final success = await provider.purchasePackage(package);
              if (success && context.mounted) {
                // Determine which tier was bought for the message
                String planName = "Subscription";
                if (package.identifier.contains('pro')) planName = "Pro";
                if (package.identifier.contains('ultimate')) {
                  planName = "Ultimate";
                }

                Navigator.of(context).pop();
                Dialogs.showSnackBar(
                    context, "$planName Plan Activated Successfully!");
              } else if (context.mounted && !provider.isPurchasing) {
                if (provider.lastPurchaseCancelled) {
                  Dialogs.showSnackBar(context, "Purchase cancelled.");
                } else {
                  Dialogs.showErrorSnackBar(
                      context, "Purchase failed. Please try again.");
                }
              }
            },
    );

    if (isBestValue) {
      return Stack(
        clipBehavior: Clip.none,
        children: [
          cardContent,
          Positioned(
            top: 0,
            right: 0,
            child: _buildBestValueBadge(color),
          ),
        ],
      );
    }

    return cardContent;
  }

  Widget _restorePurchaseButton(
      BuildContext context, RevenueCatProvider provider) {
    return OutlinedButton.icon(
      icon: const Icon(Icons.restore_rounded),
      label: const Text(
        "Restore Purchases",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.blue,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        side: BorderSide(width: 2, color: Colors.blue.withOpacity(0.5)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      onPressed: () async {
        final bool success = await provider.restorePurchases();

        if (!context.mounted) return;
        if (success) {
          if (provider.isPremium) {
            Dialogs.showSnackBar(context, "Purchases Restored Successfully!");
            Navigator.of(context).pop();
          } else {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text(
                  "No active subscriptions found to restore.",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.white),
                ),
                backgroundColor: Colors.orange.shade800,
              ),
            );
          }
        } else {
          Dialogs.showErrorSnackBar(
              context, "Restore failed. Please try again.");
        }
      },
    );
  }
}

// Simple extension to replicate firstWhereOrNull without extra package imports
extension IterableExtension<T> on Iterable<T> {
  T? get firstOrNull {
    return isEmpty ? null : first;
  }
}
