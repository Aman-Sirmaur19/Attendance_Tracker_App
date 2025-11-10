import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../widgets/custom_text.dart';
import '../../widgets/custom_banner_ad.dart';

class HelpCentreScreen extends StatefulWidget {
  const HelpCentreScreen({super.key});

  @override
  State<HelpCentreScreen> createState() => _HelpCentreScreenState();
}

class _HelpCentreScreenState extends State<HelpCentreScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  List<Map<String, String>> faqs = [];
  List<Map<String, String>> filteredFaqs = [];

  @override
  void initState() {
    super.initState();
    faqs = [
      // SETTINGS
      {
        'category': 'Settings',
        'question': "Where can I add floating '+' button?",
        'answer': "You can enable it in 'Settings'.",
      },
      {
        'category': 'Settings',
        'question': "How can I change 'Notify Me Before' time?",
        'answer': "You can change it in 'Settings'.",
      },

      // ATTENDANCE
      {
        'category': 'Attendance',
        'question': "How can I delete Attendance & To-Do tasks?",
        'answer': "Swipe the cards LEFT <- RIGHT to delete.",
      },
      {
        'category': 'Attendance',
        'question': "Where can I set notifications?",
        'answer':
            "You can set notifications by tapping on the 'Edit' icon beside 'Sticky Notes' in Attendance Screen.",
      },
      {
        'category': 'Attendance',
        'question': "How can I update attendance?",
        'answer': "Attendance can be updated by tapping on the cards.",
      },
      {
        'category': 'Attendance',
        'question': "Where can I find sticky notes?",
        'answer':
            "Sticky notes are visible when you add an attendance subject.",
      },
      {
        'category': 'Attendance',
        'question': "How can I enable overall attendance percentage (%)?",
        'answer': "You can enable it in 'Settings'.",
      },
      {
        'category': 'Attendance',
        'question': "Where can I change graph & its colour?",
        'answer': "You can change them in 'Settings'.",
      },

      // ROUTINE
      {
        'category': 'Routine',
        'question': "How can I delete all routines from routine table?",
        'answer':
            "Click on the RESET button present in the appbar of 'Routine'.",
      },
      {
        'category': 'Routine',
        'question': "Can I change Start time & End time of routine table?",
        'answer':
            "Yes, click on 'Settings Button' inside the 'Routine' screen.",
      },

      // OTHERS
      {
        'category': 'Others',
        'question':
            "How can I report bugs / issues, suggest ideas or request a feature?",
        'answer': "Go to 'Dashboard' -> 'Suggestions / Bug reports'.",
      },
      {
        'category': 'Others',
        'question': "How can I contribute to this project?",
        'answer':
            "You can contribute by visiting my GitHub via 'Developer' section in 'Dashboard'.",
      },
    ];

    filteredFaqs = List.from(faqs);
    _searchController.addListener(_filterFaqs);
  }

  void _filterFaqs() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredFaqs = faqs.where((faq) {
        final question = faq['question']!.toLowerCase();
        final answer = faq['answer']!.toLowerCase();
        final category = faq['category']!.toLowerCase();
        return question.contains(query) ||
            answer.contains(query) ||
            category.contains(query);
      }).toList();
    });
  }

  void _startSearch() {
    setState(() => _isSearching = true);
  }

  void _stopSearch() {
    setState(() {
      _isSearching = false;
      _searchController.clear();
      filteredFaqs = List.from(faqs);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Widget _customExpansionTile({
    required String title,
    required String subtitle,
    required BuildContext context,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: ExpansionTile(
        collapsedBackgroundColor:
            Theme.of(context).colorScheme.primaryContainer,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        collapsedShape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        collapsedIconColor: Colors.grey,
        iconColor: Colors.grey,
        tilePadding: const EdgeInsets.symmetric(horizontal: 10),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(10),
                bottomRight: Radius.circular(10),
              ),
              color: Theme.of(context).colorScheme.primary,
            ),
            child: Text(
              subtitle,
              style: const TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildFaqSections(BuildContext context) {
    final grouped = <String, List<Map<String, String>>>{};
    for (var faq in filteredFaqs) {
      grouped.putIfAbsent(faq['category']!, () => []).add(faq);
    }

    return grouped.entries.map((entry) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (entry.key == 'Attendance') ...[
            SizedBox(height: 10),
            CustomBannerAd(),
          ],
          const SizedBox(height: 15),
          CustomText(text: entry.key),
          ...entry.value.map((faq) => _customExpansionTile(
                title: faq['question']!,
                subtitle: faq['answer']!,
                context: context,
              )),
        ],
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        _stopSearch();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: _isSearching
              ? IconButton(
                  icon: const Icon(CupertinoIcons.chevron_back),
                  onPressed: _stopSearch,
                )
              : IconButton(
                  icon: const Icon(CupertinoIcons.chevron_back),
                  tooltip: 'Back',
                  onPressed: () => Navigator.of(context).pop(),
                ),
          title: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) =>
                FadeTransition(opacity: animation, child: child),
            child: _isSearching
                ? TextField(
                    key: const ValueKey('searchField'),
                    controller: _searchController,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: 'Search FAQs...',
                      hintStyle: const TextStyle(color: Colors.grey),
                      border: InputBorder.none,
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded,
                                  color: Colors.grey),
                              onPressed: () {
                                _searchController.clear();
                                FocusScope.of(context).unfocus();
                                _stopSearch();
                              },
                            )
                          : null,
                    ),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                      fontSize: 16,
                    ),
                  )
                : Text(
                    'FAQs',
                    key: const ValueKey('titleText'),
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary),
                  ),
          ),
          actions: [
            if (!_isSearching)
              IconButton(
                tooltip: 'Search',
                icon: const Icon(Icons.search_rounded),
                onPressed: _startSearch,
              ),
          ],
        ),
        bottomNavigationBar: const CustomBannerAd(),
        body: ListView(
          padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
          children: [
            if (filteredFaqs.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Text(
                    'No results found.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ),
              )
            else
              ..._buildFaqSections(context),
          ],
        ),
      ),
    );
  }
}
