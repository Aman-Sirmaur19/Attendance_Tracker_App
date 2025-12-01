import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../widgets/custom_banner_ad.dart';
import '../../providers/navigation_provider.dart';
import '../../providers/revenue_cat_provider.dart';
import '../dashboard/dashboard_screen.dart';
import '../dashboard/subscriptions_screen.dart';
import 'cricket_game.dart';
import 'flip_card_game.dart';
import 'magic_words_game.dart';
import 'minesweeper_game.dart';
import 'arrow_shooting_game.dart';

class AllGamesScreen extends StatelessWidget {
  const AllGamesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Define Game Data
    final List<GameItem> games = [
      GameItem(
        title: 'Flip Cards',
        icon: Icons.android_rounded,
        image: 'card',
        color: Colors.blue.shade400,
        page: const FlipCardGame(),
      ),
      // GameItem(
      //   title: 'Shoot Target',
      //   icon: Icons.arrow_forward_rounded,
      //   color: Colors.red.shade400,
      //   page: const ArrowShootingGame(),
      // ),
      // GameItem(
      //   title: 'Magic Words',
      //   icon: CupertinoIcons.wand_stars,
      //   color: Colors.purple.shade400,
      //   page: const MagicWordsGame(),
      // ),
      GameItem(
        title: 'Minesweeper',
        icon: CupertinoIcons.burst,
        image: 'minesweeper',
        color: Colors.orange.shade400,
        page: const MinesweeperGame(),
      ),
      GameItem(
        title: 'Cricket',
        icon: Icons.sports_cricket_rounded,
        image: 'cricket',
        color: Colors.green.shade600,
        page: const CricketGame(),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            context.read<NavigationProvider>().increment();
            Navigator.push(
                context,
                CupertinoPageRoute(
                    builder: (context) => const DashboardScreen()));
          },
          tooltip: 'Dashboard',
          icon: const Icon(CupertinoIcons.square_grid_2x2),
        ),
        title: const Text('Mini Games'),
      ),
      bottomNavigationBar: const CustomBannerAd(),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: GridView.builder(
          physics: const BouncingScrollPhysics(),
          itemCount: games.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 15,
            mainAxisSpacing: 10,
            childAspectRatio: 0.8, // Adjusts the height relative to width
          ),
          itemBuilder: (context, index) {
            final game = games[index];
            return _GameGridTile(game: game);
          },
        ),
      ),
    );
  }
}

class _GameGridTile extends StatelessWidget {
  final GameItem game;

  const _GameGridTile({required this.game});

  @override
  Widget build(BuildContext context) {
    bool isUltimate =
        Provider.of<RevenueCatProvider>(context, listen: false).isUltimate;
    return Material(
      color: game.color,
      borderRadius: BorderRadius.circular(20),
      elevation: 4,
      child: InkWell(
        onTap: () {
          context.read<NavigationProvider>().increment();
          Navigator.push(
              context,
              CupertinoPageRoute(
                  builder: (context) => isUltimate
                      ? game.page
                      : SubscriptionsScreen(initialIndex: 1)));
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                game.color,
                game.color.withOpacity(0.8),
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Center Image/Icon
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: game.image.isNotEmpty
                      ? Image.asset(
                          'assets/images/${game.image}.png',
                          width: 100,
                        )
                      : Icon(
                          game.icon,
                          size: 50,
                          color: Colors.white,
                        ),
                ),
              ),
              const SizedBox(height: 10),
              // Bottom Text
              Text(
                game.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Helper Class to store game data
class GameItem {
  final String title;
  final IconData icon;
  final String image;
  final Color color;
  final Widget page;

  GameItem({
    required this.title,
    required this.icon,
    this.image = '',
    required this.color,
    required this.page,
  });
}
