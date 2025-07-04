import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../main.dart';
import '../utils/dialogs.dart';
import '../services/ad_manager.dart';
import '../widgets/custom_banner_ad.dart';
import 'settings_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  Future<void> _launchInBrowser(BuildContext context, Uri url) async {
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      Dialogs.showErrorSnackBar(context, 'Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Back',
          icon: const Icon(CupertinoIcons.chevron_back),
        ),
        centerTitle: true,
        title: Text(
          'Dashboard',
          style: TextStyle(color: Theme.of(context).colorScheme.secondary),
        ),
      ),
      bottomNavigationBar: const CustomBannerAd(),
      body: Column(
        children: [
          const Text(
            'Version: 1.1.9',
            textAlign: TextAlign.center,
            style: TextStyle(
              letterSpacing: 1.5,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
              children: [
                ListTile(
                  tileColor: Theme.of(context).colorScheme.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  onTap: () {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Coming soon...',
                                style: TextStyle(
                                  letterSpacing: 1,
                                  fontWeight: FontWeight.bold,
                                )),
                            Spacer(),
                            Text('🔔'),
                          ],
                        ),
                        // backgroundColor: Colors.black87,
                        duration: Duration(seconds: 2),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  leading:
                      const Icon(Icons.star_rate_rounded, color: Colors.amber),
                  title: RichText(
                    text: const TextSpan(
                      text: 'Attendance',
                      style: TextStyle(
                        fontSize: 18,
                        fontFamily: 'Fredoka',
                        color: Colors.lightBlue,
                        fontWeight: FontWeight.bold,
                      ),
                      children: [
                        TextSpan(
                          text: 'Tracker',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.red,
                            fontFamily: 'Fredoka',
                            fontWeight: FontWeight.bold,
                          ),
                          children: [
                            TextSpan(
                              text: ' Pro',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.amber,
                                fontFamily: 'Fredoka',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  trailing: const Icon(
                    CupertinoIcons.chevron_forward,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 20),
                _customListTile(
                  onTap: () => AdManager()
                      .navigateWithAd(context, const SettingsScreen()),
                  icon: CupertinoIcons.settings,
                  title: 'Settings',
                  isFirst: true,
                  context: context,
                ),
                _customListTile(
                  onTap: () async {
                    const String appUrl =
                        'https://play.google.com/store/apps/details?id=com.sirmaur.attendance_tracker';
                    Share.share(
                        'Check out this awesome Attendance Tracker app:\n\n$appUrl');
                  },
                  icon: CupertinoIcons.share,
                  title: 'Share with friends',
                  context: context,
                ),
                _customListTile(
                  onTap: () async {
                    const url =
                        'https://play.google.com/store/apps/developer?id=SIRMAUR';
                    _launchInBrowser(context, Uri.parse(url));
                  },
                  icon: CupertinoIcons.app_badge,
                  title: 'More Apps',
                  isLast: true,
                  context: context,
                ),
                const SizedBox(height: 20),
                _customListTile(
                  onTap: () => showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          backgroundColor: Colors.blue.shade200,
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(50),
                                child: Image.asset(
                                  'assets/images/avatar.png',
                                  width: 100,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Aman Sirmaur',
                                style: TextStyle(
                                  fontSize: 20,
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                  letterSpacing: 1,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(top: mq.width * .01),
                                child: Text(
                                  'MECHANICAL ENGINEERING',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(top: mq.width * .03),
                                child: Text(
                                  'NIT AGARTALA',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          content: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              InkWell(
                                child: Image.asset('assets/images/youtube.png',
                                    width: 30),
                                onTap: () async {
                                  const url =
                                      'https://www.youtube.com/@AmanSirmaur';
                                  _launchInBrowser(context, Uri.parse(url));
                                },
                              ),
                              InkWell(
                                child: Image.asset('assets/images/twitter.png',
                                    width: 30),
                                onTap: () async {
                                  const url =
                                      'https://x.com/AmanSirmaur?t=2QWiqzkaEgpBFNmLI38sbA&s=09';
                                  _launchInBrowser(context, Uri.parse(url));
                                },
                              ),
                              InkWell(
                                child: Image.asset(
                                    'assets/images/instagram.png',
                                    width: 30),
                                onTap: () async {
                                  const url =
                                      'https://www.instagram.com/aman_sirmaur19/';
                                  _launchInBrowser(context, Uri.parse(url));
                                },
                              ),
                              InkWell(
                                child: Image.asset('assets/images/github.png',
                                    width: 30),
                                onTap: () async {
                                  const url =
                                      'https://github.com/Aman-Sirmaur19';
                                  _launchInBrowser(context, Uri.parse(url));
                                },
                              ),
                              InkWell(
                                child: Image.asset('assets/images/linkedin.png',
                                    width: 30),
                                onTap: () async {
                                  const url =
                                      'https://www.linkedin.com/in/aman-kumar-257613257/';
                                  _launchInBrowser(context, Uri.parse(url));
                                },
                              ),
                            ],
                          ),
                        );
                      }),
                  icon: Icons.copyright_rounded,
                  title: 'Developer',
                  isFirst: true,
                  isLast: true,
                  context: context,
                ),
                const SizedBox(height: 20),
                _customListTile(
                  onTap: () async {
                    const url =
                        'https://play.google.com/store/apps/details?id=com.sirmaur.shreemad_bhagavad_geeta';
                    _launchInBrowser(context, Uri.parse(url));
                  },
                  tileColor: Colors.amber,
                  imageUrl:
                      'https://play-lh.googleusercontent.com/L4FMm88yMoWIKhUX3U1XJTmvd8_MkoQUX4IfN61QBSq51GWpnMPvs4Dz7gpmlmXspA=w480-h960-rw',
                  title: 'Shreemad Bhagavad Geeta',
                  subtitle:
                      'The Divine Song of God\nAvailable in 100+ global languages',
                  context: context,
                  isFirst: true,
                  isLast: true,
                ),
                const SizedBox(height: 10),
                _customListTile(
                  onTap: () async {
                    const url =
                        'https://play.google.com/store/apps/details?id=com.sirmaur.habito';
                    _launchInBrowser(context, Uri.parse(url));
                  },
                  tileColor: Colors.deepPurpleAccent,
                  imageUrl:
                      'https://play-lh.googleusercontent.com/6pVzCQ-zskiVRkDHCfplR_2JNIUgotMHc_5wGG3EsQR9maMJeIoIhWjpkk4qyR_-UZ5a=w480-h960-rw',
                  title: 'HabitO - Habit Tracker',
                  subtitle:
                      'Track your daily habits on beautiful colorful heatmap.',
                  context: context,
                  isFirst: true,
                  isLast: true,
                ),
              ],
            ),
          ),
          const Text(
            'MADE WITH ❤️ IN 🇮🇳',
            textAlign: TextAlign.center,
            style: TextStyle(
              letterSpacing: 1.5,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _customListTile({
    required void Function() onTap,
    required String title,
    required BuildContext context,
    Color? tileColor,
    IconData? icon,
    String? imageUrl,
    String? subtitle,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return ListTile(
      tileColor: tileColor ?? Theme.of(context).colorScheme.primary,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
        topLeft: isFirst ? const Radius.circular(20) : Radius.zero,
        topRight: isFirst ? const Radius.circular(20) : Radius.zero,
        bottomLeft: isLast ? const Radius.circular(20) : Radius.zero,
        bottomRight: isLast ? const Radius.circular(20) : Radius.zero,
      )),
      onTap: onTap,
      leading: imageUrl != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.network(
                imageUrl,
                width: 45,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.broken_image_rounded,
                    size: 45,
                    color: Colors.white,
                  );
                },
              ))
          : Icon(icon),
      title: Text(
        title,
        style: subtitle != null
            ? TextStyle(
                color: title.contains('Geeta') ? Colors.black : Colors.white,
                fontWeight: FontWeight.bold,
              )
            : null,
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(
                  color: title.contains('Geeta') ? Colors.black : Colors.white),
            )
          : null,
      trailing: subtitle == null
          ? const Icon(
              CupertinoIcons.chevron_forward,
              color: Colors.grey,
            )
          : null,
    );
  }
}
