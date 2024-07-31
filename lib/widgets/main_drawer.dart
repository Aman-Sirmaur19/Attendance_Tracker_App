import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:url_launcher/url_launcher.dart';

import '../main.dart';

class MainDrawer extends StatefulWidget {
  const MainDrawer({super.key});

  @override
  State<MainDrawer> createState() => _MainDrawerState();
}

class _MainDrawerState extends State<MainDrawer> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          gradient: LinearGradient(colors: [
        Theme.of(context).colorScheme.inversePrimary,
        Colors.blue.shade400,
      ], begin: Alignment.topRight, end: Alignment.bottomLeft)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: mq.height * .05),
            child: Row(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: mq.width * .02),
                  child: const CircleAvatar(
                    radius: 35,
                    backgroundImage: AssetImage('assets/images/avatar.png'),
                  ),
                ),
                const Text(
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
            () {
              // Navigator.push(context,
              //     MaterialPageRoute(builder: (_) => const LeaderboardScreen()));
            },
          ),
          buildListTile(
            'More Apps!',
            CupertinoIcons.app_badge,
            () {},
          ),
          const Spacer(),
          Padding(
            padding: EdgeInsets.only(bottom: mq.height * .02),
            child: InkWell(
              onTap: () => showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(mq.width * .15),
                            child: Image.asset(
                              'assets/images/Aman Kumar.heic',
                              width: mq.width * .3,
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
                                width: mq.width * .07),
                            onTap: () async {
                              const url =
                                  'https://www.linkedin.com/in/aman-kumar-257613257/';
                              setState(() {
                                _launchInBrowser(Uri.parse(url));
                              });
                            },
                          ),
                          InkWell(
                            child: Image.asset('assets/images/github.png',
                                width: mq.width * .07),
                            onTap: () async {
                              const url = 'https://github.com/Aman-Sirmaur19';
                              setState(() {
                                _launchInBrowser(Uri.parse(url));
                              });
                            },
                          ),
                          InkWell(
                            child: Image.asset('assets/images/instagram.png',
                                width: mq.width * .07),
                            onTap: () async {
                              const url =
                                  'https://www.instagram.com/aman_sirmaur19/';
                              setState(() {
                                _launchInBrowser(Uri.parse(url));
                              });
                            },
                          ),
                          InkWell(
                            child: Image.asset('assets/images/twitter.png',
                                width: mq.width * .07),
                            onTap: () async {
                              const url =
                                  'https://x.com/AmanSirmaur?t=2QWiqzkaEgpBFNmLI38sbA&s=09';
                              setState(() {
                                _launchInBrowser(Uri.parse(url));
                              });
                            },
                          ),
                          InkWell(
                            child: Image.asset('assets/images/youtube.png',
                                width: mq.width * .07),
                            onTap: () async {
                              const url =
                                  'https://www.youtube.com/@AmanSirmaur';
                              setState(() {
                                _launchInBrowser(Uri.parse(url));
                              });
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
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.copyright_rounded, color: Colors.white),
                  Text(
                    'Aman Sirmaur',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

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

  Future<void> _launchInBrowser(Uri url) async {
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Couldn\'t launch URL!',
              style: TextStyle(color: Colors.white, letterSpacing: 1)),
          backgroundColor: Colors.red.withOpacity(.8),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
