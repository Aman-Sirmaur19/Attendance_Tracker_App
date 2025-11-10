import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../../utils/dialogs.dart';
import '../../providers/revenue_cat_provider.dart';

// --- UPDATED: Single feature list for PRO ---
const List<String> _proFeatures = [
  "Remove Ads",
  "Full Settings Access",
  "All Upcoming Features",
];
// ---------------------------------

class SubscriptionsScreen extends StatelessWidget {
  const SubscriptionsScreen({super.key});

  // --- REMOVED: Single _proColor. Colors are now specific. ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () => Navigator.pop(context),
            tooltip: 'Back',
            icon: const Icon(CupertinoIcons.chevron_back)),
        title: const Text("Go Pro"),
        elevation: 2.0,
      ),
      body: Consumer<RevenueCatProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            // --- UPDATED: Use a specific color for the loader ---
            return const Center(
                child: CircularProgressIndicator(color: Colors.blue));
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

          // --- Filter packages based on your new IDs ---
          final packages = offering.availablePackages;
          final Package? proMonthly =
              packages.firstWhereOrNull((p) => p.identifier == 'pro_monthly');
          final Package? proYearly =
              packages.firstWhereOrNull((p) => p.identifier == 'pro_yearly');
          // ------------------------

          return Stack(
            children: [
              _buildPlanPage(
                context: context,
                provider: provider,
                title: "PRO",
                slogan: "Unlock all features.",
                features: _proFeatures,
                monthlyPackage: proMonthly,
                yearlyPackage: proYearly,
                // --- REMOVED: Single color property ---
                hasActiveEntitlement: provider.isPro,
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
    required BuildContext context, // Needs context
    required RevenueCatProvider provider,
    required String title,
    required String slogan,
    required List<String> features,
    required Package? monthlyPackage,
    required Package? yearlyPackage,
    required bool hasActiveEntitlement,
    // --- REMOVED: Single color property ---
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
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
          ...features.map((feature) => _buildFeatureListItem(
              context, feature, Colors.blue // <-- UPDATED: Color changed
              )),
          const SizedBox(height: 50),
          if (monthlyPackage != null)
            _buildSubscriptionCard(
              context,
              provider: provider,
              package: monthlyPackage,
              color: Colors.pink, // <-- UPDATED: Color changed
              isBestValue: false,
            ),
          const SizedBox(height: 16),
          if (yearlyPackage != null)
            _buildSubscriptionCard(
              context,
              provider: provider,
              package: yearlyPackage,
              color: Colors.deepPurpleAccent, // <-- UPDATED: Color changed
              isBestValue: true,
            ),
          const SizedBox(height: 16),
          if (hasActiveEntitlement)
            Center(
              child: Text(
                "This is your current plan.",
                style: TextStyle(
                    color: Colors.green, // <-- UPDATED: Color changed
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
              ),
            ),

          // --- Show restore button if user is not already premium ---
          if (!provider.isPro) ...[
            const SizedBox(height: 5),
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
            color: color, // <-- This will now be green
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
        color: color, // <-- This will be pink or purple
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
    required Color color, // <-- This will be pink or purple
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
        // This is your custom title logic, it remains unchanged
        '${product.title.split('(').first}(${product.subscriptionPeriod == 'P1M' ? 'Monthly' : 'Yearly'})',
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(
        product.priceString,
        style: TextStyle(
          fontSize: 20, // Kept your font size change
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
                Navigator.of(context).pop();
                Dialogs.showSnackBar(context, "Purchase Successful!");
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
    // This button remains blue as requested
    return OutlinedButton.icon(
      icon: const Icon(Icons.restore_rounded),
      label: const Text(
        "Restore Purchases",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.blue,
        side: BorderSide(width: 2, color: Colors.blue.withOpacity(0.5)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
      onPressed: () async {
        final bool success = await provider.restorePurchases();

        if (!context.mounted) return;
        if (success) {
          if (provider.isPro) {
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
