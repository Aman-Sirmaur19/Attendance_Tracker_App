import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:url_launcher/url_launcher.dart';

import '../main.dart';
import '../screens/settings_screen.dart';
import 'dialogs.dart';

class MainDrawer extends StatelessWidget {
  const MainDrawer({super.key});

  Widget buildListTile(String title, IconData icon, VoidCallback tapHandler) {
    return ListTile(
      leading: Icon(icon, size: 30, color: Colors.white),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      onTap: tapHandler,
    );
  }

  Future<void> _launchInBrowser(BuildContext context, Uri url) async {
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      Dialogs.showErrorSnackBar(context, 'Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
          Theme.of(context).colorScheme.inversePrimary,
          Colors.blue.shade400,
        ], begin: Alignment.topRight, end: Alignment.bottomLeft)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: mq.height * .05),
              child: const Row(
                children: [
                  SizedBox(width: 15),
                  CircleAvatar(
                    radius: 35,
                    backgroundImage: AssetImage('assets/images/avatar.png'),
                  ),
                  SizedBox(width: 10),
                  Text(
                    'Hey Buddy!',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 25,
                      color: Color.fromARGB(255, 95, 48, 237),
                    ),
                  )
                ],
              ),
            ),
            SizedBox(height: mq.height * .03),
            buildListTile(
              'Info',
              CupertinoIcons.info,
              () => showDialog(
                  context: context,
                  builder: (context) => const AlertDialog(
                        title: Text(
                          'NOTE',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        content: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Divider(),
                            Text(
                              '\n\u2022 Swipe the cards to delete.\n',
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '\u2022 Copyright section is \'clickable\'.',
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      )),
            ),
            buildListTile(
              'Settings',
              CupertinoIcons.settings,
              () => Navigator.push(context,
                  CupertinoPageRoute(builder: (_) => const SettingsScreen())),
            ),
            buildListTile(
              'More Apps!',
              CupertinoIcons.app_badge,
              () async {
                const url =
                    'https://play.google.com/store/apps/developer?id=SIRMAUR';
                _launchInBrowser(context, Uri.parse(url));
              },
            ),
            buildListTile(
              'Copyright',
              Icons.copyright_rounded,
              () => showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
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
                              color: Theme.of(context).colorScheme.secondary,
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
                                color: Theme.of(context).colorScheme.secondary,
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
                                color: Theme.of(context).colorScheme.secondary,
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
                            child: Image.asset('assets/images/linkedin.png',
                                width: 30),
                            onTap: () async {
                              const url =
                                  'https://www.linkedin.com/in/aman-kumar-257613257/';
                              _launchInBrowser(context, Uri.parse(url));
                            },
                          ),
                          InkWell(
                            child: Image.asset('assets/images/github.png',
                                width: 30),
                            onTap: () async {
                              const url = 'https://github.com/Aman-Sirmaur19';
                              _launchInBrowser(context, Uri.parse(url));
                            },
                          ),
                          InkWell(
                            child: Image.asset('assets/images/instagram.png',
                                width: 30),
                            onTap: () async {
                              const url =
                                  'https://www.instagram.com/aman_sirmaur19/';
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
                            child: Image.asset('assets/images/youtube.png',
                                width: 30),
                            onTap: () async {
                              const url =
                                  'https://www.youtube.com/@AmanSirmaur';
                              _launchInBrowser(context, Uri.parse(url));
                            },
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('Close'),
                        ),
                      ],
                    );
                  }),
            ),
            const Spacer(),
            Padding(
              padding: EdgeInsets.only(bottom: mq.height * .02),
              child: const Text('MADE WITH ❤️ IN 🇮🇳',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  )),
            ),
          ],
        ),
      ),
    );
  }
}
