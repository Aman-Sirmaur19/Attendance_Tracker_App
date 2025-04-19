import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../main.dart';
import '../utils/dialogs.dart';
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
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
              physics: const BouncingScrollPhysics(),
              children: [
                _customContainer(
                    context: context,
                    child: ListTile(
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
                      leading: const Icon(Icons.star_rate_rounded,
                          color: Colors.amber),
                      title: RichText(
                        text: const TextSpan(
                          text: 'Attendance',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.lightBlue,
                          ),
                          children: [
                            TextSpan(
                              text: 'Tracker',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                              children: [
                                TextSpan(
                                  text: ' Pro',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.amber,
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
                    )),
                const SizedBox(height: 20),
                _customContainer(
                  context: context,
                  child: Column(
                    children: [
                      _customListTile(
                        () => Navigator.push(
                            context,
                            CupertinoPageRoute(
                                builder: (_) => const SettingsScreen())),
                        CupertinoIcons.settings,
                        'Settings',
                      ),
                      _customListTile(
                        () async {
                          const url =
                              'https://play.google.com/store/apps/developer?id=SIRMAUR';
                          _launchInBrowser(context, Uri.parse(url));
                        },
                        CupertinoIcons.app_badge,
                        'More Apps',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _customContainer(
                  context: context,
                  child: Column(
                    children: [
                      _customListTile(
                        () => showDialog(
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
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                    Padding(
                                      padding:
                                          EdgeInsets.only(top: mq.width * .01),
                                      child: Text(
                                        'MECHANICAL ENGINEERING',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .secondary,
                                          letterSpacing: 1,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding:
                                          EdgeInsets.only(top: mq.width * .03),
                                      child: Text(
                                        'NIT AGARTALA',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w900,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .secondary,
                                          letterSpacing: 1,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                content: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    InkWell(
                                      child: Image.asset(
                                          'assets/images/youtube.png',
                                          width: 30),
                                      onTap: () async {
                                        const url =
                                            'https://www.youtube.com/@AmanSirmaur';
                                        _launchInBrowser(
                                            context, Uri.parse(url));
                                      },
                                    ),
                                    InkWell(
                                      child: Image.asset(
                                          'assets/images/twitter.png',
                                          width: 30),
                                      onTap: () async {
                                        const url =
                                            'https://x.com/AmanSirmaur?t=2QWiqzkaEgpBFNmLI38sbA&s=09';
                                        _launchInBrowser(
                                            context, Uri.parse(url));
                                      },
                                    ),
                                    InkWell(
                                      child: Image.asset(
                                          'assets/images/instagram.png',
                                          width: 30),
                                      onTap: () async {
                                        const url =
                                            'https://www.instagram.com/aman_sirmaur19/';
                                        _launchInBrowser(
                                            context, Uri.parse(url));
                                      },
                                    ),
                                    InkWell(
                                      child: Image.asset(
                                          'assets/images/github.png',
                                          width: 30),
                                      onTap: () async {
                                        const url =
                                            'https://github.com/Aman-Sirmaur19';
                                        _launchInBrowser(
                                            context, Uri.parse(url));
                                      },
                                    ),
                                    InkWell(
                                      child: Image.asset(
                                          'assets/images/linkedin.png',
                                          width: 30),
                                      onTap: () async {
                                        const url =
                                            'https://www.linkedin.com/in/aman-kumar-257613257/';
                                        _launchInBrowser(
                                            context, Uri.parse(url));
                                      },
                                    ),
                                  ],
                                ),
                              );
                            }),
                        Icons.copyright_rounded,
                        'Copyright',
                      ),
                    ],
                  ),
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

  Widget _customContainer({
    required BuildContext context,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Theme.of(context).colorScheme.primary,
      ),
      child: child,
    );
  }

  Widget _customListTile(void Function() onTap, IconData icon, String title) {
    return ListTile(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      onTap: onTap,
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(
        CupertinoIcons.chevron_forward,
        color: Colors.grey,
      ),
    );
  }
}
