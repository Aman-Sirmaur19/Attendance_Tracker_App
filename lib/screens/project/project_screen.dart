import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../main.dart';
import '../../utils/dialogs.dart';
import '../../models/project.dart';
import '../../providers/project_provider.dart';
import '../../providers/navigation_provider.dart';
import '../../providers/revenue_cat_provider.dart';
import '../../widgets/add_button.dart';
import '../../widgets/custom_banner_ad.dart';
import '../../widgets/custom_elevated_button.dart';
import '../dashboard/dashboard_screen.dart';
import '../dashboard/subscriptions_screen.dart';
import 'subject_tile.dart';
import 'preview_subject_tile.dart';

final List<Color> _subjectColors = [
  Colors.pink[300]!,
  Colors.deepPurpleAccent[400]!,
  Colors.lightGreen[600]!,
  Colors.deepOrange[400]!,
  Colors.blue[500]!,
  Colors.brown[400]!,
  Colors.cyan[600]!,
  Colors.red[400]!,
  Colors.blueGrey[500]!,
  Colors.purpleAccent,
  Colors.lime[500]!,
  Colors.amber[700]!,
  Colors.teal[400]!,
];

enum SubjectFilter { all, due }

class ProjectScreen extends StatefulWidget {
  const ProjectScreen({super.key});

  @override
  State<ProjectScreen> createState() => _ProjectScreenState();
}

class _ProjectScreenState extends State<ProjectScreen> {
  SubjectFilter _filterMode = SubjectFilter.all;

  Project _getDummyProject() {
    final p = Project.create(title: 'Demo Project');

    // Subject 1
    final s1 = ProjectSubject.create(title: 'App Development');

    // Chapter 1
    final c1 = ProjectChapter.create(title: 'Flutter Basics');

    // Topic 1
    final t1 = ProjectTopic.create(title: 'Widgets');
    t1.subTopics.add(
        ProjectSubTopic.create(title: 'StatelessWidget')..isCompleted = true);
    t1.subTopics.add(
        ProjectSubTopic.create(title: 'StatefulWidget')..isCompleted = true);
    t1.subTopics.add(ProjectSubTopic.create(title: 'InheritedWidget'));
    c1.topics.add(t1);

    // Topic 2
    final t2 = ProjectTopic.create(title: 'Layouts');
    t2.subTopics.add(ProjectSubTopic.create(title: 'Row & Column'));
    t2.subTopics.add(ProjectSubTopic.create(title: 'Stack & Positioned'));
    c1.topics.add(t2);

    s1.chapters.add(c1);

    // Chapter 2
    final c2 = ProjectChapter.create(title: 'State Management');
    final t3 = ProjectTopic.create(title: 'Providers');
    t3.subTopics.add(ProjectSubTopic.create(title: 'ChangeNotifier'));
    c2.topics.add(t3);

    s1.chapters.add(c2);
    p.subjects.add(s1);

    // Subject 2
    final s2 = ProjectSubject.create(title: 'Backend Integration');
    final c3 = ProjectChapter.create(title: 'Firebase');
    final t4 = ProjectTopic.create(title: 'Authentication');
    t4.subTopics.add(ProjectSubTopic.create(title: 'Email Sign-in'));
    t4.subTopics.add(ProjectSubTopic.create(title: 'Google Sign-in'));
    c3.topics.add(t4);
    s2.chapters.add(c3);
    p.subjects.add(s2);

    return p;
  }

  @override
  Widget build(BuildContext context) {
    final base = BaseWidget.of(context);
    final mq = MediaQuery.of(context).size;
    final projectProvider = Provider.of<ProjectProvider>(context);

    // Listen to the top-level Project Box
    return ValueListenableBuilder(
      valueListenable: base.dataStore.listenToProjects(),
      builder: (ctx, Box<Project> box, Widget? child) {
        final allProjects = box.values.toList();
        Project? currentProject;
        if (projectProvider.selectedProjectId != null) {
          try {
            currentProject = box.get(projectProvider.selectedProjectId);
          } catch (_) {}
        }

        // Default to first project if nothing selected or ID invalid
        if (currentProject == null && allProjects.isNotEmpty) {
          currentProject = allProjects.first;
          // Defer state update to next frame to avoid build error
          WidgetsBinding.instance.addPostFrameCallback((_) {
            projectProvider.selectProject(currentProject!.id);
          });
        }

        // 3. Get Subjects from the current project
        final allSubjects = currentProject?.subjects ?? [];

        // Apply Filter
        final displayedSubjects = _filterMode == SubjectFilter.all
            ? allSubjects
            : allSubjects.where((s) => !s.isCompleted).toList();

        final dueCount = allSubjects.where((s) => !s.isCompleted).length;

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
            title: const Text('Project Tracker'),
            actions: [
              if (!context.watch<RevenueCatProvider>().isPremium)
                IconButton(
                  icon: const Icon(Icons.account_tree_rounded),
                  tooltip: 'Structure Preview',
                  onPressed: () =>
                      _showStructurePreview(context, _getDummyProject()),
                ),
            ],
          ),
          bottomNavigationBar: const CustomBannerAd(),
          body: allProjects.isEmpty
              ? _buildNoProjectsState(context, base)
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // 1. Wrap the InkWell in Expanded to constrain its width
                          Flexible(
                            child: InkWell(
                              onTap: () => _showProjectSelectorSheet(
                                context: context,
                                base: base,
                                box: box,
                                provider: projectProvider,
                              ),
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0,
                                  vertical: 4.0,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Theme.of(context).colorScheme.surface,
                                  border: Border.all(
                                    width: 2,
                                    color: Colors.blue.withOpacity(.5),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // 2. Flexible here allows Text to shrink within the Expanded parent
                                    Flexible(
                                      child: Text(
                                        currentProject?.title ??
                                            'Select Project',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        // Truncates with ...
                                        style: const TextStyle(
                                          fontSize: 16,
                                          letterSpacing: .75,
                                          color: Colors.blue,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    const Icon(
                                      CupertinoIcons.chevron_down,
                                      size: 18,
                                      color: Colors.blue,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Add some spacing between selector and filters

                          // 3. SegmentedButton remains as is; Expanded above ensures this stays visible
                          SegmentedButton<SubjectFilter>(
                            segments: [
                              ButtonSegment<SubjectFilter>(
                                value: SubjectFilter.all,
                                label: Text(
                                  'All (${allSubjects.length})',
                                  style: const TextStyle(height: 1),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              ButtonSegment<SubjectFilter>(
                                value: SubjectFilter.due,
                                label: Text(
                                  'Due ($dueCount)',
                                  style: const TextStyle(height: 1),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                            showSelectedIcon: false,
                            selected: {_filterMode},
                            onSelectionChanged:
                                (Set<SubjectFilter> newSelection) {
                              setState(() {
                                _filterMode = newSelection.first;
                              });
                            },
                            style: ButtonStyle(
                              visualDensity: VisualDensity.compact,
                              elevation: WidgetStateProperty.all(0),
                              side: WidgetStateProperty.all(BorderSide.none),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              padding: WidgetStateProperty.all(EdgeInsets.zero),
                              shape: WidgetStateProperty.all(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              backgroundColor:
                                  WidgetStateProperty.resolveWith<Color>(
                                (states) {
                                  if (states.contains(WidgetState.selected)) {
                                    return Colors.blue;
                                  }
                                  return Theme.of(context).colorScheme.primary;
                                },
                              ),
                              foregroundColor:
                                  WidgetStateProperty.resolveWith<Color>(
                                (states) {
                                  if (states.contains(WidgetState.selected)) {
                                    return Colors.white;
                                  }
                                  return Colors.blue;
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // --- List View ---
                    Expanded(
                      child: allSubjects.isEmpty
                          ? _buildEmptySubjectState(context, currentProject!)
                          : ListView.builder(
                              physics: const BouncingScrollPhysics(),
                              padding: EdgeInsets.only(
                                left: 10,
                                right: 10,
                                top: 5,
                                bottom: mq.height * 0.1,
                              ),
                              itemCount: displayedSubjects.length + 1,
                              itemBuilder: (context, index) {
                                if (index == displayedSubjects.length) {
                                  return AddButton(
                                    label: 'Add New Subject',
                                    color: Colors.blue,
                                    onPressed: () => Dialogs.showAddEditDialog(
                                      context,
                                      title: 'Add Subject',
                                      onSave: (val) {
                                        // Add subject to current project list
                                        currentProject!.subjects.add(
                                            ProjectSubject.create(title: val));
                                        // Save the Project Object
                                        currentProject.save();
                                      },
                                    ),
                                  );
                                }

                                final subject = displayedSubjects[index];
                                final originalIndex =
                                    allSubjects.indexOf(subject);
                                final color = _subjectColors[
                                    originalIndex % _subjectColors.length];

                                return SubjectTile(
                                  subject: subject,
                                  color: color,
                                  parentProject:
                                      currentProject!, // Pass parent to save on updates
                                );
                              },
                            ),
                    ),
                  ],
                ),
        );
      },
    );
  }

  void _showStructurePreview(BuildContext context, Project project) {
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.primary,
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          minChildSize: 0.4,
          maxChildSize: 1.0,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.account_tree_rounded,
                        color: Colors.blue,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          project.title,
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(
                  height: .5,
                  thickness: .5,
                  indent: 20,
                  endIndent: 20,
                  color: Colors.grey,
                ),
                Expanded(
                  child: project.subjects.isEmpty
                      ? const Center(
                          child: Text(
                            "No structure to preview.\nAdd some subjects first!",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          controller: scrollController,
                          padding: const EdgeInsets.only(
                              left: 10, right: 10, top: 10, bottom: 40),
                          itemCount: project.subjects.length,
                          itemBuilder: (ctx, i) {
                            final subject = project.subjects[i];
                            final color =
                                _subjectColors[i % _subjectColors.length];
                            // Use the specialized Preview Tile that replicates the exact UI
                            return PreviewSubjectTile(
                                subject: subject, color: color);
                          },
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showProjectSelectorSheet({
    required BuildContext context,
    required BaseWidget base,
    required Box<Project> box,
    required ProjectProvider provider,
  }) {
    showModalBottomSheet(
        context: context,
        showDragHandle: true,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        builder: (ctx) {
          // Re-query values inside sheet to keep it updated
          final projects = box.values.toList();
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Select Project',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: projects.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 5),
                      itemBuilder: (context, index) {
                        final p = projects[index];
                        final isSelected = p.id == provider.selectedProjectId;
                        return ListTile(
                          tileColor: Theme.of(context).colorScheme.surface,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15)),
                          title: Text(
                            p.title,
                            style: TextStyle(
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isSelected ? Colors.blue : null,
                            ),
                          ),
                          onTap: () {
                            provider.selectProject(p.id);
                            Navigator.pop(context);
                          },
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: () {
                                  Navigator.pop(context); // Close sheet first
                                  Dialogs.showAddEditDialog(context,
                                      title: 'Rename Project',
                                      initialText: p.title, onSave: (val) {
                                    p.title = val;
                                    p.save();
                                  });
                                },
                                tooltip: 'Edit',
                                icon: const Icon(Icons.edit_outlined, size: 20),
                              ),
                              IconButton(
                                onPressed: () {
                                  Navigator.pop(context); // Close sheet first
                                  Dialogs.confirmDelete(context, () {
                                    // If deleting selected, clear selection in provider
                                    if (p.id == provider.selectedProjectId) {
                                      provider.clearSelection();
                                    }
                                    p.delete();
                                  }, p.title);
                                },
                                tooltip: 'Delete',
                                icon: const Icon(
                                  Icons.delete_outline_rounded,
                                  size: 20,
                                  color: Colors.redAccent,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: CustomElevatedButton(
                      title: 'Create New Project',
                      onPressed: () {
                        Navigator.pop(context);
                        if (Provider.of<RevenueCatProvider>(context,
                                listen: false)
                            .isUltimate) {
                          Dialogs.showAddEditDialog(context,
                              title: 'New Project Name', onSave: (val) {
                            final newProject = Project.create(title: val);
                            base.dataStore.addProject(project: newProject);
                            provider.selectProject(newProject.id);
                          });
                        } else {
                          context.read<NavigationProvider>().increment();
                          Navigator.push(
                              context,
                              CupertinoPageRoute(
                                  builder: (context) =>
                                      const SubscriptionsScreen(
                                          initialIndex: 1)));
                        }
                      },
                    ),
                  )
                ],
              ),
            ),
          );
        });
  }

  Widget _buildNoProjectsState(BuildContext context, BaseWidget base) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/no-project.png', width: 150),
            const SizedBox(height: 20),
            const Text(
              'Great things are achieved by\na series of small steps!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            CustomElevatedButton(
              title: 'Create Project',
              onPressed: () {
                if (Provider.of<RevenueCatProvider>(context, listen: false)
                    .isPremium) {
                  Dialogs.showAddEditDialog(
                    context,
                    title: 'Project Name',
                    onSave: (val) {
                      final newProject = Project.create(title: val);
                      base.dataStore.addProject(project: newProject);
                      // Provider will auto-select in build method or we can do it here
                      Provider.of<ProjectProvider>(context, listen: false)
                          .selectProject(newProject.id);
                    },
                  );
                } else {
                  context.read<NavigationProvider>().increment();
                  Navigator.push(
                      context,
                      CupertinoPageRoute(
                          builder: (context) => const SubscriptionsScreen()));
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptySubjectState(BuildContext context, Project project) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/empty-project.png', width: 125),
            const SizedBox(height: 20),
            const Text(
              'Break it down to\nbuild it up!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            CustomElevatedButton(
              title: 'Add Subject',
              onPressed: () => Dialogs.showAddEditDialog(
                context,
                title: 'Add Subject',
                onSave: (val) {
                  project.subjects.add(ProjectSubject.create(title: val));
                  project.save();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
